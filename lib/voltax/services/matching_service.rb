require_relative "../money"
require_relative "../repositories/ledger_repository"
require_relative "../repositories/market_repository"
require_relative "../repositories/order_repository"
require_relative "../repositories/trade_receipt_repository"
require_relative "../repositories/trade_repository"
require_relative "../repositories/wallet_repository"

module VoltaX
  module Services
    class MatchingService
      class SettlementError < StandardError; end

      def initialize(database:)
        @database = database
      end

      def match_order(order_id:)
        database.transaction do
          incoming = order_repository.lock_by_id(order_id)
          raise SettlementError, "Incoming order not found" unless incoming

          market = market_repository.find_by_id(incoming[:market_id])
          raise SettlementError, "Market not found" unless market

          candidates_for(incoming).each do |resting|
            incoming = order_repository.lock_by_id(order_id)
            break unless matchable_state?(incoming)
            next unless crosses?(incoming: incoming, resting: resting)
            next if incoming[:user_id] == resting[:user_id]

            settle_fill(incoming: incoming, resting: resting, market: market)
          end

          order_repository.lock_by_id(order_id)
        end
      end

      private

      attr_reader :database

      def candidates_for(incoming)
        opposite_side = incoming[:side] == "buy" ? "sell" : "buy"
        order_repository.lock_match_candidates(market_id: incoming[:market_id], side: opposite_side)
      end

      def crosses?(incoming:, resting:)
        return false unless matchable_state?(resting)
        return false unless incoming[:market_id] == resting[:market_id]
        return resting[:limit_price] <= incoming[:limit_price] if incoming[:side] == "buy"

        resting[:limit_price] >= incoming[:limit_price]
      end

      def matchable_state?(order)
        order && %w[open partially_filled].include?(order[:status]) && Money.positive?(order[:remaining_quantity])
      end

      def settle_fill(incoming:, resting:, market:)
        quantity = min_decimal(incoming[:remaining_quantity], resting[:remaining_quantity])
        execution_price = resting[:limit_price]
        quote_amount = execution_price * quantity
        buy_order = incoming[:side] == "buy" ? incoming : resting
        sell_order = incoming[:side] == "sell" ? incoming : resting

        trade = trade_repository.create(
          market_id: market[:id],
          buy_order_id: buy_order[:id],
          sell_order_id: sell_order[:id],
          maker_order_id: resting[:id],
          taker_order_id: incoming[:id],
          execution_price: execution_price,
          executed_quantity: quantity,
          quote_amount: quote_amount,
          aggressor_side: incoming[:side]
        )

        settle_wallets(
          trade: trade,
          market: market,
          buy_order: buy_order,
          sell_order: sell_order,
          execution_price: execution_price,
          quantity: quantity,
          quote_amount: quote_amount
        )
        create_receipts(
          trade: trade,
          market: market,
          buy_order: buy_order,
          sell_order: sell_order,
          resting_order_id: resting[:id],
          execution_price: execution_price,
          quantity: quantity,
          quote_amount: quote_amount
        )
        apply_fill(order: incoming, quantity: quantity)
        apply_fill(order: resting, quantity: quantity)
      end

      def settle_wallets(trade:, market:, buy_order:, sell_order:, execution_price:, quantity:, quote_amount:)
        buyer_quote_wallet = locked_wallet(user_id: buy_order[:user_id], asset: market[:quote_asset],
                                           needed: quote_amount)
        seller_base_wallet = locked_wallet(user_id: sell_order[:user_id], asset: market[:base_asset], needed: quantity)
        buyer_base_wallet = available_wallet(user_id: buy_order[:user_id], asset: market[:base_asset])
        seller_quote_wallet = available_wallet(user_id: sell_order[:user_id], asset: market[:quote_asset])

        spend_locked(user_id: buy_order[:user_id], wallet: buyer_quote_wallet, asset: market[:quote_asset],
                     amount: quote_amount, trade_id: trade[:id])
        spend_locked(user_id: sell_order[:user_id], wallet: seller_base_wallet, asset: market[:base_asset],
                     amount: quantity, trade_id: trade[:id])
        release_available(user_id: buy_order[:user_id], wallet: buyer_base_wallet, asset: market[:base_asset],
                          amount: quantity, trade_id: trade[:id])
        release_available(user_id: sell_order[:user_id], wallet: seller_quote_wallet, asset: market[:quote_asset],
                          amount: quote_amount, trade_id: trade[:id])

        surplus = (buy_order[:limit_price] - execution_price) * quantity
        unlock_locked(user_id: buy_order[:user_id], wallet: buyer_quote_wallet, asset: market[:quote_asset],
                      amount: surplus, trade_id: trade[:id]) if Money.positive?(surplus)
      end

      def create_receipts(trade:, market:, buy_order:, sell_order:, resting_order_id:, execution_price:, quantity:,
                          quote_amount:)
        trade_receipt_repository.create(
          trade_id: trade[:id],
          user_id: buy_order[:user_id],
          order_id: buy_order[:id],
          side: "buy",
          liquidity_role: buy_order[:id] == resting_order_id ? "maker" : "taker",
          market_symbol: market[:symbol],
          price: execution_price,
          quantity: quantity,
          quote_amount: quote_amount,
          debit_asset: market[:quote_asset],
          debit_amount: quote_amount,
          credit_asset: market[:base_asset],
          credit_amount: quantity,
          client_order_id: buy_order[:client_order_id],
          client_reference: buy_order[:client_reference]
        )
        trade_receipt_repository.create(
          trade_id: trade[:id],
          user_id: sell_order[:user_id],
          order_id: sell_order[:id],
          side: "sell",
          liquidity_role: sell_order[:id] == resting_order_id ? "maker" : "taker",
          market_symbol: market[:symbol],
          price: execution_price,
          quantity: quantity,
          quote_amount: quote_amount,
          debit_asset: market[:base_asset],
          debit_amount: quantity,
          credit_asset: market[:quote_asset],
          credit_amount: quote_amount,
          client_order_id: sell_order[:client_order_id],
          client_reference: sell_order[:client_reference]
        )
      end

      def apply_fill(order:, quantity:)
        filled = order[:filled_quantity] + quantity
        remaining = order[:remaining_quantity] - quantity
        order_repository.update_fill(
          order_id: order[:id],
          filled_quantity: filled,
          remaining_quantity: remaining,
          status: remaining.zero? ? "filled" : "partially_filled"
        )
      end

      def locked_wallet(user_id:, asset:, needed:)
        wallet = wallet_repository.lock_by_user_and_asset(user_id: user_id, asset: asset)
        raise SettlementError, "Locked wallet unavailable" unless wallet && wallet[:locked_balance] >= needed

        wallet
      end

      def available_wallet(user_id:, asset:)
        wallet_repository.create_if_missing(user_id: user_id, asset: asset)
        wallet_repository.lock_by_user_and_asset(user_id: user_id, asset: asset)
      end

      def spend_locked(user_id:, wallet:, asset:, amount:, trade_id:)
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: "locked",
          amount: -amount,
          entry_type: "spend",
          reference_type: "trade",
          reference_id: trade_id.to_s
        )
        wallet_repository.apply_delta(
          wallet_id: wallet[:id],
          user_id: user_id,
          available_delta: Money.zero,
          locked_delta: -amount
        )
      end

      def release_available(user_id:, wallet:, asset:, amount:, trade_id:)
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: "available",
          amount: amount,
          entry_type: "release",
          reference_type: "trade",
          reference_id: trade_id.to_s
        )
        wallet_repository.apply_delta(
          wallet_id: wallet[:id],
          user_id: user_id,
          available_delta: amount,
          locked_delta: Money.zero
        )
      end

      def unlock_locked(user_id:, wallet:, asset:, amount:, trade_id:)
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: "locked",
          amount: -amount,
          entry_type: "unlock",
          reference_type: "trade",
          reference_id: trade_id.to_s
        )
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: "available",
          amount: amount,
          entry_type: "unlock",
          reference_type: "trade",
          reference_id: trade_id.to_s
        )
        wallet_repository.apply_delta(
          wallet_id: wallet[:id],
          user_id: user_id,
          available_delta: amount,
          locked_delta: -amount
        )
      end

      def min_decimal(left, right)
        left <= right ? left : right
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def order_repository
        @order_repository ||= Repositories::OrderRepository.new(database: database)
      end

      def trade_repository
        @trade_repository ||= Repositories::TradeRepository.new(database: database)
      end

      def trade_receipt_repository
        @trade_receipt_repository ||= Repositories::TradeReceiptRepository.new(database: database)
      end

      def wallet_repository
        @wallet_repository ||= Repositories::WalletRepository.new(database: database)
      end

      def ledger_repository
        @ledger_repository ||= Repositories::LedgerRepository.new(database: database)
      end
    end
  end
end
