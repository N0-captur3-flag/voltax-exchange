require_relative "../account_profiles"
require_relative "../money"
require_relative "../repositories/ledger_repository"
require_relative "../repositories/market_repository"
require_relative "../repositories/trade_receipt_repository"
require_relative "../repositories/trade_repository"
require_relative "../repositories/wallet_repository"

module VoltaX
  module Services
    class RFQSettlementService
      class SettlementError < StandardError; end
      class Forbidden < StandardError; end
      class NotFound < StandardError; end
      class InsufficientFunds < StandardError; end
      class QuoteNotAcceptable < StandardError; end

      def initialize(database:)
        @database = database
      end

      def accept(user_id:, rfq_id:, quote_id:)
        database.transaction do
          rfq = lock_rfq(rfq_id)
          raise NotFound unless rfq
          raise Forbidden unless rfq[:user_id] == user_id
          validate_rfq!(rfq)

          quote = lock_quote(rfq_id: rfq_id, quote_id: quote_id)
          validate_quote!(quote)
          validate_liquidity_account!(quote[:maker_user_id])

          market = market_repository.find_by_id(rfq[:market_id])
          raise SettlementError, "Market not found" unless market && market[:status] == "active"

          quantity = Money.coerce_decimal(quote[:quantity])
          price = Money.coerce_decimal(quote[:price])
          quote_amount = price * quantity
          participants = participants_for(rfq: rfq, quote: quote, market: market, quantity: quantity,
                                          quote_amount: quote_amount)

          debit_wallets = lock_debit_wallets(participants)
          verify_available!(participants: participants, wallets: debit_wallets)
          credit_wallets = lock_credit_wallets(participants)
          timestamp = Time.now.utc
          orders = create_order_anchors(rfq: rfq, quote: quote, market: market, quantity: quantity,
                                        price: price, timestamp: timestamp)
          trade = create_trade(rfq: rfq, quote: quote, market: market, orders: orders, quantity: quantity,
                               price: price, quote_amount: quote_amount)

          apply_debits(participants: participants, wallets: debit_wallets, trade: trade, rfq: rfq)
          apply_credits(participants: participants, wallets: credit_wallets, trade: trade, rfq: rfq)
          create_receipts(rfq: rfq, quote: quote, market: market, orders: orders, trade: trade,
                          quantity: quantity, price: price, quote_amount: quote_amount, participants: participants)
          accept_quote_and_settle_rfq(rfq_id: rfq[:id], quote_id: quote[:id], timestamp: timestamp)

          {
            rfq: rfqs.where(id: rfq[:id]).first,
            quote: rfq_quotes.where(id: quote[:id]).first,
            trade: trade
          }
        end
      end

      private

      attr_reader :database

      def lock_rfq(id)
        rfqs.where(id: id).for_update.first
      end

      def lock_quote(rfq_id:, quote_id:)
        rfq_quotes.where(rfq_id: rfq_id, id: quote_id).for_update.first
      end

      def validate_rfq!(rfq)
        raise QuoteNotAcceptable unless %w[open quoted].include?(rfq[:status])
        raise QuoteNotAcceptable unless timestamp(rfq[:expires_at]) > Time.now.utc
      end

      def validate_quote!(quote)
        raise QuoteNotAcceptable unless quote && quote[:status] == "submitted"
        raise QuoteNotAcceptable unless timestamp(quote[:expires_at]) > Time.now.utc
      end

      def validate_liquidity_account!(user_id)
        user = database[:users].where(id: user_id).for_update.first
        raise QuoteNotAcceptable unless AccountProfiles.can?(user, "rfq_quote")
      end

      def participants_for(rfq:, quote:, market:, quantity:, quote_amount:)
        if rfq[:side] == "buy"
          {
            owner: {
              user_id: rfq[:user_id],
              side: "buy",
              debit_asset: market[:quote_asset],
              debit_amount: quote_amount,
              credit_asset: market[:base_asset],
              credit_amount: quantity
            },
            maker: {
              user_id: quote[:maker_user_id],
              side: "sell",
              debit_asset: market[:base_asset],
              debit_amount: quantity,
              credit_asset: market[:quote_asset],
              credit_amount: quote_amount
            }
          }
        else
          {
            owner: {
              user_id: rfq[:user_id],
              side: "sell",
              debit_asset: market[:base_asset],
              debit_amount: quantity,
              credit_asset: market[:quote_asset],
              credit_amount: quote_amount
            },
            maker: {
              user_id: quote[:maker_user_id],
              side: "buy",
              debit_asset: market[:quote_asset],
              debit_amount: quote_amount,
              credit_asset: market[:base_asset],
              credit_amount: quantity
            }
          }
        end
      end

      def lock_debit_wallets(participants)
        participants.transform_values do |participant|
          wallet_repository.lock_by_user_and_asset(
            user_id: participant[:user_id],
            asset: participant[:debit_asset]
          )
        end
      end

      def verify_available!(participants:, wallets:)
        participants.each do |role, participant|
          wallet = wallets.fetch(role)
          unless wallet && wallet[:available_balance] >= participant[:debit_amount]
            raise InsufficientFunds
          end
        end
      end

      def lock_credit_wallets(participants)
        participants.transform_values do |participant|
          wallet_repository.create_if_missing(user_id: participant[:user_id], asset: participant[:credit_asset])
          wallet_repository.lock_by_user_and_asset(user_id: participant[:user_id], asset: participant[:credit_asset])
        end
      end

      def create_order_anchors(rfq:, quote:, market:, quantity:, price:, timestamp:)
        owner_order = insert_order_anchor(
          user_id: rfq[:user_id],
          market_id: market[:id],
          side: rfq[:side],
          price: price,
          quantity: quantity,
          client_order_id: "rfq-#{rfq[:id]}-owner",
          timestamp: timestamp
        )
        maker_order = insert_order_anchor(
          user_id: quote[:maker_user_id],
          market_id: market[:id],
          side: opposite_side(rfq[:side]),
          price: price,
          quantity: quantity,
          client_order_id: "rfq-#{rfq[:id]}-maker",
          timestamp: timestamp
        )
        {
          owner: owner_order,
          maker: maker_order,
          buy: rfq[:side] == "buy" ? owner_order : maker_order,
          sell: rfq[:side] == "sell" ? owner_order : maker_order
        }
      end

      def insert_order_anchor(user_id:, market_id:, side:, price:, quantity:, client_order_id:, timestamp:)
        id = orders.insert(
          user_id: user_id,
          market_id: market_id,
          side: side,
          order_type: "limit",
          limit_price: price,
          original_quantity: quantity,
          filled_quantity: quantity,
          remaining_quantity: Money.zero,
          status: "filled",
          client_order_id: client_order_id,
          execution_memo: nil,
          created_at: timestamp,
          updated_at: timestamp,
          cancelled_at: nil
        )
        orders.where(id: id).first
      end

      def create_trade(rfq:, quote:, market:, orders:, quantity:, price:, quote_amount:)
        trade_repository.create(
          market_id: market[:id],
          buy_order_id: orders[:buy][:id],
          sell_order_id: orders[:sell][:id],
          maker_order_id: orders[:maker][:id],
          taker_order_id: orders[:owner][:id],
          execution_price: price,
          executed_quantity: quantity,
          quote_amount: quote_amount,
          aggressor_side: rfq[:side]
        )
      end

      def apply_debits(participants:, wallets:, trade:, rfq:)
        participants.each do |role, participant|
          wallet = wallets.fetch(role)
          append_ledger(
            user_id: participant[:user_id],
            wallet: wallet,
            asset: participant[:debit_asset],
            amount: -participant[:debit_amount],
            entry_type: "spend",
            trade: trade,
            rfq: rfq
          )
          wallet_repository.apply_delta(
            wallet_id: wallet[:id],
            user_id: participant[:user_id],
            available_delta: -participant[:debit_amount],
            locked_delta: Money.zero
          )
        end
      end

      def apply_credits(participants:, wallets:, trade:, rfq:)
        participants.each do |role, participant|
          wallet = wallets.fetch(role)
          append_ledger(
            user_id: participant[:user_id],
            wallet: wallet,
            asset: participant[:credit_asset],
            amount: participant[:credit_amount],
            entry_type: "release",
            trade: trade,
            rfq: rfq
          )
          wallet_repository.apply_delta(
            wallet_id: wallet[:id],
            user_id: participant[:user_id],
            available_delta: participant[:credit_amount],
            locked_delta: Money.zero
          )
        end
      end

      def append_ledger(user_id:, wallet:, asset:, amount:, entry_type:, trade:, rfq:)
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: "available",
          amount: amount,
          entry_type: entry_type,
          reference_type: "rfq",
          reference_id: "#{rfq[:id]}:trade:#{trade[:id]}"
        )
      end

      def create_receipts(rfq:, quote:, market:, orders:, trade:, quantity:, price:, quote_amount:, participants:)
        create_receipt(
          trade: trade,
          user_id: rfq[:user_id],
          order: orders[:owner],
          side: participants[:owner][:side],
          liquidity_role: "taker",
          market: market,
          price: price,
          quantity: quantity,
          quote_amount: quote_amount,
          debit_asset: participants[:owner][:debit_asset],
          debit_amount: participants[:owner][:debit_amount],
          credit_asset: participants[:owner][:credit_asset],
          credit_amount: participants[:owner][:credit_amount],
          client_reference: rfq[:delivery_terms]
        )
        create_receipt(
          trade: trade,
          user_id: quote[:maker_user_id],
          order: orders[:maker],
          side: participants[:maker][:side],
          liquidity_role: "maker",
          market: market,
          price: price,
          quantity: quantity,
          quote_amount: quote_amount,
          debit_asset: participants[:maker][:debit_asset],
          debit_amount: participants[:maker][:debit_amount],
          credit_asset: participants[:maker][:credit_asset],
          credit_amount: participants[:maker][:credit_amount],
          client_reference: nil
        )
      end

      def create_receipt(trade:, user_id:, order:, side:, liquidity_role:, market:, price:, quantity:, quote_amount:,
                         debit_asset:, debit_amount:, credit_asset:, credit_amount:, client_reference:)
        trade_receipt_repository.create(
          trade_id: trade[:id],
          user_id: user_id,
          order_id: order[:id],
          side: side,
          liquidity_role: liquidity_role,
          market_symbol: market[:symbol],
          price: price,
          quantity: quantity,
          quote_amount: quote_amount,
          debit_asset: debit_asset,
          debit_amount: debit_amount,
          credit_asset: credit_asset,
          credit_amount: credit_amount,
          client_order_id: order[:client_order_id],
          client_reference: client_reference
        )
      end

      def accept_quote_and_settle_rfq(rfq_id:, quote_id:, timestamp:)
        rfq_quotes.where(id: quote_id).update(status: "accepted", updated_at: timestamp)
        rfq_quotes.where(rfq_id: rfq_id, status: "submitted").exclude(id: quote_id).update(
          status: "rejected",
          updated_at: timestamp
        )
        rfqs.where(id: rfq_id).update(
          status: "settled",
          accepted_quote_id: quote_id,
          updated_at: timestamp
        )
      end

      def opposite_side(side)
        side == "buy" ? "sell" : "buy"
      end

      def timestamp(value)
        return value.utc if value.is_a?(Time)
        return value.to_time.utc if value.respond_to?(:to_time)

        raise QuoteNotAcceptable
      end

      def rfqs
        database[:rfqs]
      end

      def rfq_quotes
        database[:rfq_quotes]
      end

      def orders
        database[:orders]
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def wallet_repository
        @wallet_repository ||= Repositories::WalletRepository.new(database: database)
      end

      def ledger_repository
        @ledger_repository ||= Repositories::LedgerRepository.new(database: database)
      end

      def trade_repository
        @trade_repository ||= Repositories::TradeRepository.new(database: database)
      end

      def trade_receipt_repository
        @trade_receipt_repository ||= Repositories::TradeReceiptRepository.new(database: database)
      end
    end
  end
end
