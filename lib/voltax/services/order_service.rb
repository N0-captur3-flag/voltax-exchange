require_relative "../money"
require_relative "../repositories/ledger_repository"
require_relative "../repositories/market_repository"
require_relative "../repositories/order_repository"
require_relative "../repositories/trade_receipt_repository"
require_relative "../repositories/trade_repository"
require_relative "../repositories/wallet_repository"
require_relative "matching_service"
require_relative "order_reference_resolver"

module VoltaX
  module Services
    class OrderService
      class InvalidRequest < StandardError; end
      class InsufficientFunds < StandardError; end
      class ClientOrderIdTaken < StandardError; end
      class Forbidden < StandardError; end
      class NotFound < StandardError; end

      def initialize(database:)
        @database = database
      end

      def place(user_id:, market_symbol:, side:, order_type:, limit_price:, quantity:, client_order_id: nil,
                execution_memo: nil, booking_ref: nil)
        database.transaction do
          market = active_market!(market_symbol)
          side = normalize_side(side)
          order_type = normalize_order_type(order_type)
          limit_price = parse_aligned_decimal(limit_price, market[:tick_size], "limit_price")
          quantity = parse_aligned_decimal(quantity, market[:lot_size], "quantity")
          lock_asset, lock_amount = lock_requirement(market: market, side: side, limit_price: limit_price,
                                                     quantity: quantity)

          wallet = wallet_repository.lock_by_user_and_asset(user_id: user_id, asset: lock_asset)
          raise InsufficientFunds unless wallet && wallet[:available_balance] >= lock_amount

          order = order_repository.create(
            user_id: user_id,
            market_id: market[:id],
            side: side,
            order_type: order_type,
            limit_price: limit_price,
            original_quantity: quantity,
            client_order_id: client_order_id,
            execution_memo: execution_memo,
            client_reference: booking_ref
          )

          lock_funds(user_id: user_id, wallet: wallet, asset: lock_asset, amount: lock_amount, order_id: order[:id])
          matching_service.match_order(order_id: order[:id])
        end
      rescue Sequel::UniqueConstraintViolation
        raise ClientOrderIdTaken
      rescue ArgumentError
        raise InvalidRequest
      end

      def list_for_user(user_id:)
        orders = order_repository.list_for_user(user_id: user_id)
        market_symbols = market_symbols_for(orders.map { |order| order[:market_id] })
        orders.map { |order| [order, market_symbols.fetch(order[:market_id])] }
      end

      def find_for_user(user_id:, order_id:)
        order_id = parse_id(order_id)
        order = order_repository.find_by_id_for_user(user_id: user_id, id: order_id)
        raise NotFound unless order

        [order, market_symbol_for(order[:market_id])]
      rescue ArgumentError
        raise InvalidRequest
      end

      def resolve_order_reference(account:, reference_code:)
        order = order_reference_resolver.resolve(account: account, reference_code: reference_code)
        raise NotFound unless order

        [order, market_symbol_for(order[:market_id])]
      rescue ArgumentError
        raise InvalidRequest
      end

      def cancel(user_id:, order_id:)
        order_id = parse_id(order_id)

        database.transaction do
          existing = database[:orders].where(id: order_id).for_update.first
          raise NotFound unless existing
          raise Forbidden unless existing[:user_id] == user_id
          raise InvalidRequest unless %w[open partially_filled].include?(existing[:status])

          market = market_repository.find_by_id(existing[:market_id])
          lock_asset, unlock_amount = lock_requirement(
            market: market,
            side: existing[:side],
            limit_price: existing[:limit_price],
            quantity: existing[:remaining_quantity]
          )
          wallet = wallet_repository.lock_by_user_and_asset(user_id: user_id, asset: lock_asset)
          raise InvalidRequest unless wallet
          raise InvalidRequest if wallet[:locked_balance] < unlock_amount

          unlock_funds(user_id: user_id, wallet: wallet, asset: lock_asset, amount: unlock_amount, order_id: order_id)
          order_repository.cancel_for_user(user_id: user_id, id: order_id)
        end.then { |order| [order, market_symbol_for(order[:market_id])] }
      rescue ArgumentError
        raise InvalidRequest
      end

      def orderbook(market_symbol:, depth: nil)
        market = active_market!(market_symbol)
        depth = normalize_depth(depth)
        rows = database[:orders]
          .where(market_id: market[:id], status: %w[open partially_filled])
          .where { remaining_quantity > 0 }
          .select_group(:side, :limit_price)
          .select_append { sum(remaining_quantity).as(quantity) }
          .all

        bids = rows.select { |row| row[:side] == "buy" }
          .map { |row| { price: row[:limit_price], quantity: row[:quantity] } }
          .sort_by { |row| [-row[:price], row[:quantity]] }
        asks = rows.select { |row| row[:side] == "sell" }
          .map { |row| { price: row[:limit_price], quantity: row[:quantity] } }
          .sort_by { |row| [row[:price], row[:quantity]] }
        bids = bids.first(depth) if depth
        asks = asks.first(depth) if depth

        { market_symbol: market[:symbol], bids: bids, asks: asks }
      rescue ArgumentError
        raise InvalidRequest
      end

      def trades_for_market(market_symbol:)
        market = active_market!(market_symbol)
        trade_repository.list_public_trades_for_market(market_id: market[:id]).map { |trade| [trade, market[:symbol]] }
      rescue ArgumentError
        raise InvalidRequest
      end

      def public_trade(trade_id:)
        trade = trade_repository.find_public_trade(trade_id)
        raise NotFound unless trade

        [trade, market_symbol_for(trade[:market_id])]
      rescue ArgumentError
        raise InvalidRequest
      end

      def participant_trade_detail(user_id:, trade_id:)
        trade_id = parse_id(trade_id)
        trade = trade_repository.find_by_id(trade_id)
        raise NotFound unless trade

        receipt = trade_receipt_repository.find_by_trade_for_user(user_id: user_id, trade_id: trade_id)
        raise NotFound unless receipt

        booking_rows = trade_receipt_repository.bookings_for_execution(trade_id: trade_id)

        [trade, market_symbol_for(trade[:market_id]), receipt, booking_rows]
      rescue ArgumentError
        raise InvalidRequest
      end

      def receipt_for_user(user_id:, trade_id:)
        trade_id = parse_id(trade_id)
        raise NotFound unless trade_repository.find_by_id(trade_id)

        receipt = trade_receipt_repository.find_by_trade_for_user(user_id: user_id, trade_id: trade_id)
        raise NotFound unless receipt

        receipt
      rescue ArgumentError
        raise InvalidRequest
      end

      private

      attr_reader :database

      def active_market!(symbol)
        market = market_repository.find_by_symbol(symbol.to_s)
        raise InvalidRequest unless market && market[:status] == "active"

        market
      end

      def normalize_side(side)
        normalized = side.to_s
        raise InvalidRequest unless %w[buy sell].include?(normalized)

        normalized
      end

      def normalize_order_type(order_type)
        normalized = order_type.to_s
        raise InvalidRequest unless normalized == "limit"

        normalized
      end

      def parse_aligned_decimal(value, increment, field)
        decimal = Money.parse(value)
        raise InvalidRequest unless Money.positive?(decimal)
        raise InvalidRequest unless (decimal % Money.coerce_decimal(increment)).zero?

        decimal
      rescue ArgumentError
        raise InvalidRequest, "#{field} is invalid"
      end

      def parse_id(value)
        text = value.to_s
        raise ArgumentError unless text.match?(/\A[1-9]\d*\z/)

        Integer(text, 10)
      end

      def normalize_depth(value)
        return nil if value.nil?

        text = value.to_s
        raise ArgumentError unless text.match?(/\A[1-9]\d*\z/)

        depth = Integer(text, 10)
        raise ArgumentError if depth > 100

        depth
      end

      def lock_requirement(market:, side:, limit_price:, quantity:)
        return [market[:quote_asset], limit_price * quantity] if side == "buy"

        [market[:base_asset], quantity]
      end

      def lock_funds(user_id:, wallet:, asset:, amount:, order_id:)
        ledger_lock(user_id: user_id, wallet: wallet, asset: asset, bucket: "available", amount: -amount,
                    order_id: order_id)
        ledger_lock(user_id: user_id, wallet: wallet, asset: asset, bucket: "locked", amount: amount,
                    order_id: order_id)
        wallet_repository.apply_delta(
          wallet_id: wallet[:id],
          user_id: user_id,
          available_delta: -amount,
          locked_delta: amount
        )
      end

      def unlock_funds(user_id:, wallet:, asset:, amount:, order_id:)
        ledger_unlock(user_id: user_id, wallet: wallet, asset: asset, bucket: "locked", amount: -amount,
                      order_id: order_id)
        ledger_unlock(user_id: user_id, wallet: wallet, asset: asset, bucket: "available", amount: amount,
                      order_id: order_id)
        wallet_repository.apply_delta(
          wallet_id: wallet[:id],
          user_id: user_id,
          available_delta: amount,
          locked_delta: -amount
        )
      end

      def ledger_lock(user_id:, wallet:, asset:, bucket:, amount:, order_id:)
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: bucket,
          amount: amount,
          entry_type: "lock",
          reference_type: "order",
          reference_id: order_id.to_s
        )
      end

      def ledger_unlock(user_id:, wallet:, asset:, bucket:, amount:, order_id:)
        ledger_repository.append(
          user_id: user_id,
          wallet_id: wallet[:id],
          asset: asset,
          balance_bucket: bucket,
          amount: amount,
          entry_type: "unlock",
          reference_type: "order",
          reference_id: order_id.to_s
        )
      end

      def market_symbol_for(market_id)
        market_repository.find_by_id(market_id).fetch(:symbol)
      end

      def market_symbols_for(market_ids)
        market_ids.uniq.to_h { |id| [id, market_repository.find_by_id(id).fetch(:symbol)] }
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def order_repository
        @order_repository ||= Repositories::OrderRepository.new(database: database)
      end

      def order_reference_resolver
        @order_reference_resolver ||= OrderReferenceResolver.new(
          directory: reference_directory
        )
      end

      def reference_directory
        @reference_directory ||= ReferenceDirectory.new(order_repository: order_repository)
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

      def matching_service
        @matching_service ||= MatchingService.new(database: database)
      end
    end
  end
end
