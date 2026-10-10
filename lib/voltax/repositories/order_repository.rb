require_relative "../money"
require_relative "../market_integrity_policy"

module VoltaX
  module Repositories
    class OrderRepository
      SIDES = %w[buy sell].freeze
      ORDER_TYPES = %w[limit].freeze
      STATUSES = %w[open partially_filled filled cancelled].freeze
      REFERENCE_CODE_PATTERN = /\A[a-zA-Z0-9_.:-]{1,64}\z/.freeze

      def initialize(database:)
        @database = database
      end

      def create(user_id:, market_id:, side:, limit_price:, original_quantity:, order_type: "limit",
                 client_order_id: nil, execution_memo: nil, client_reference: nil, status: "open")
        side = normalize_side(side)
        order_type = normalize_order_type(order_type)
        status = normalize_status(status)
        limit_price = positive_decimal(limit_price, "Limit price")
        original_quantity = positive_decimal(original_quantity, "Original quantity")
        client_order_id = normalize_reference_code(client_order_id)
        timestamp = now

        id = orders.insert(
          user_id: user_id,
          market_id: market_id,
          side: side,
          order_type: order_type,
          limit_price: limit_price,
          original_quantity: original_quantity,
          filled_quantity: Money.zero,
          remaining_quantity: original_quantity,
          status: status,
          client_order_id: client_order_id,
          execution_memo: optional_client_text(execution_memo, "Execution memo"),
          client_reference: optional_client_text(client_reference, "Booking reference"),
          created_at: timestamp,
          updated_at: timestamp,
          cancelled_at: nil
        )
        find_by_id_for_user(user_id: user_id, id: id)
      end

      def find_by_id_for_user(user_id:, id:)
        orders.where(user_id: user_id, id: id).first
      end

      def find_reference_for_account(user_id:, reference_code:)
        orders.where(user_id: user_id, client_order_id: normalize_reference_code(reference_code)).first
      end

      def list_for_user(user_id:)
        orders.where(user_id: user_id).order(:id).all
      end

      def resolve_order_reference(reference_code:)
        orders.where(client_order_id: normalize_reference_code(reference_code)).order(:id).first
      end

      def lock_by_id(id)
        orders.where(id: id).for_update.first
      end

      def lock_match_candidates(market_id:, side:)
        side = normalize_side(side)
        scope = orders.where(market_id: market_id, side: side, status: %w[open partially_filled]).for_update
        return scope.order(:limit_price, :created_at, :id).all if side == "sell"

        scope.reverse_order(:limit_price).order_more(:created_at, :id).all
      end

      def update_fill(order_id:, filled_quantity:, remaining_quantity:, status:)
        filled_quantity = Money.coerce_decimal(filled_quantity)
        remaining_quantity = Money.coerce_decimal(remaining_quantity)
        status = normalize_status(status)
        raise ArgumentError, "Filled quantity must be non-negative" if Money.negative?(filled_quantity)
        raise ArgumentError, "Remaining quantity must be non-negative" if Money.negative?(remaining_quantity)

        changed = orders.where(id: order_id).update(
          filled_quantity: filled_quantity,
          remaining_quantity: remaining_quantity,
          status: status,
          updated_at: now
        )
        raise ArgumentError, "Order not found" if changed != 1

        orders.where(id: order_id).first
      end

      def cancel_for_user(user_id:, id:)
        timestamp = now
        changed = orders.where(user_id: user_id, id: id, status: %w[open partially_filled]).update(
          status: "cancelled",
          cancelled_at: timestamp,
          updated_at: timestamp
        )
        raise ArgumentError, "Order not cancellable" if changed != 1

        find_by_id_for_user(user_id: user_id, id: id)
      end

      private

      attr_reader :database

      def orders
        database[:orders]
      end

      def normalize_side(side)
        normalized = side.to_s
        raise ArgumentError, "Order side is invalid" unless SIDES.include?(normalized)

        normalized
      end

      def normalize_order_type(order_type)
        normalized = order_type.to_s
        raise ArgumentError, "Order type is invalid" unless ORDER_TYPES.include?(normalized)

        normalized
      end

      def normalize_status(status)
        normalized = status.to_s
        raise ArgumentError, "Order status is invalid" unless STATUSES.include?(normalized)

        normalized
      end

      def normalize_reference_code(client_order_id)
        return nil if client_order_id.nil?

        normalized = client_order_id.to_s
        raise ArgumentError, "Reference code is invalid" unless normalized.match?(REFERENCE_CODE_PATTERN)

        normalized
      end

      def positive_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless Money.positive?(decimal)

        decimal
      end

      def optional_client_text(value, field)
        MarketIntegrityPolicy.optional_client_text(value, field: field)
      end

      def now
        Time.now.utc
      end
    end
  end
end
