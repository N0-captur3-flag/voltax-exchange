require_relative "../money"
require_relative "../market_integrity_policy"

module VoltaX
  module Repositories
    class TradeReceiptRepository
      SIDES = %w[buy sell].freeze
      LIQUIDITY_ROLES = %w[maker taker].freeze
      SETTLEMENT_STATUSES = %w[settled].freeze
      BOOKING_MARKER_COLUMN = :client_reference

      def initialize(database:)
        @database = database
      end

      def create(trade_id:, user_id:, order_id:, side:, liquidity_role:, market_symbol:, price:, quantity:,
                 quote_amount:, debit_asset:, debit_amount:, credit_asset:, credit_amount:, client_order_id: nil,
                 client_reference: nil, fee_asset: nil, fee_amount: Money.zero, settlement_status: "settled")
        side = normalize_side(side)
        liquidity_role = normalize_liquidity_role(liquidity_role)
        settlement_status = normalize_settlement_status(settlement_status)
        id = trade_receipts.insert(
          trade_id: trade_id,
          user_id: user_id,
          order_id: order_id,
          client_order_id: optional_string(client_order_id),
          client_reference: optional_client_text(client_reference, "Booking reference"),
          side: side,
          liquidity_role: liquidity_role,
          market_symbol: market_symbol.to_s,
          price: positive_decimal(price, "Receipt price"),
          quantity: positive_decimal(quantity, "Receipt quantity"),
          quote_amount: positive_decimal(quote_amount, "Receipt quote amount"),
          fee_asset: optional_string(fee_asset),
          fee_amount: non_negative_decimal(fee_amount, "Fee amount"),
          debit_asset: debit_asset.to_s,
          debit_amount: positive_decimal(debit_amount, "Debit amount"),
          credit_asset: credit_asset.to_s,
          credit_amount: positive_decimal(credit_amount, "Credit amount"),
          settlement_status: settlement_status,
          created_at: Time.now.utc
        )
        find_by_id_for_user(user_id: user_id, id: id)
      end

      def find_by_id_for_user(user_id:, id:)
        trade_receipts.where(user_id: user_id, id: id).first
      end

      def find_by_trade_for_user(user_id:, trade_id:)
        trade_receipts.where(user_id: user_id, trade_id: trade_id).first
      end

      def bookings_for_execution(trade_id:)
        trade_receipts.where(trade_id: trade_id).order(:id).all
      end

      def list_for_user(user_id:)
        trade_receipts.where(user_id: user_id).order(:id).all
      end

      def list_for_order_for_user(user_id:, order_id:)
        trade_receipts.where(user_id: user_id, order_id: order_id).order(:id).all
      end

      private

      attr_reader :database

      def trade_receipts
        database[:trade_receipts]
      end

      def normalize_side(side)
        normalized = side.to_s
        raise ArgumentError, "Receipt side is invalid" unless SIDES.include?(normalized)

        normalized
      end

      def normalize_liquidity_role(liquidity_role)
        normalized = liquidity_role.to_s
        raise ArgumentError, "Receipt liquidity role is invalid" unless LIQUIDITY_ROLES.include?(normalized)

        normalized
      end

      def normalize_settlement_status(settlement_status)
        normalized = settlement_status.to_s
        raise ArgumentError, "Receipt settlement status is invalid" unless SETTLEMENT_STATUSES.include?(normalized)

        normalized
      end

      def positive_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless Money.positive?(decimal)

        decimal
      end

      def non_negative_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be non-negative" if Money.negative?(decimal)

        decimal
      end

      def optional_string(value)
        return nil if value.nil?

        value.to_s
      end

      def optional_client_text(value, field)
        MarketIntegrityPolicy.optional_client_text(value, field: field)
      end
    end
  end
end
