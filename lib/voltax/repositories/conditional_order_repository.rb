require "date"

require_relative "../market_integrity_policy"
require_relative "../money"

module VoltaX
  module Repositories
    class ConditionalOrderRepository
      SIDES = %w[buy sell].freeze
      ORDER_TYPES = %w[limit].freeze
      TRIGGER_TYPES = %w[
        last_trade_price_at_or_above
        last_trade_price_at_or_below
      ].freeze
      STATUSES = %w[pending triggered placed cancelled expired rejected].freeze
      TERMINAL_STATUSES = %w[placed cancelled expired rejected].freeze
      ALLOWED_TRANSITIONS = {
        "pending" => %w[triggered cancelled expired rejected],
        "triggered" => %w[placed rejected],
        "placed" => [],
        "cancelled" => [],
        "expired" => [],
        "rejected" => []
      }.freeze
      CLIENT_ORDER_ID_PATTERN = /\A[a-zA-Z0-9_.:-]{1,64}\z/.freeze
      IDEMPOTENCY_KEY_PATTERN = /\A[a-zA-Z0-9_.:-]{8,128}\z/.freeze
      MAX_NOTE_LENGTH = 512
      DEFAULT_WORK_LIMIT = 100
      MAX_WORK_LIMIT = 500

      def initialize(database:)
        @database = database
      end

      def create(user_id:, market:, side:, trigger_type:, trigger_price:, limit_price:, quantity:,
                 client_order_id: nil, signal_context: nil, expires_at: nil)
        market = active_market!(market)
        side = normalize_side(side)
        trigger_type = normalize_trigger_type(trigger_type)
        trigger_price = positive_decimal(trigger_price, "Trigger price")
        limit_price = positive_decimal(limit_price, "Limit price")
        quantity = positive_decimal(quantity, "Quantity")
        validate_increment!(trigger_price, market[:tick_size], "Trigger price")
        validate_increment!(limit_price, market[:tick_size], "Limit price")
        validate_increment!(quantity, market[:lot_size], "Quantity")
        client_order_id = normalize_client_order_id(client_order_id)
        signal_context = optional_note(signal_context)
        expires_at = optional_future_timestamp(expires_at)
        timestamp = now

        id = conditional_orders.insert(
          user_id: user_id,
          market_id: market[:id],
          triggered_order_id: nil,
          side: side,
          order_type: "limit",
          trigger_type: trigger_type,
          trigger_price: trigger_price,
          limit_price: limit_price,
          quantity: quantity,
          status: "pending",
          client_order_id: client_order_id,
          signal_context: signal_context,
          trigger_idempotency_key: nil,
          expires_at: expires_at,
          triggered_at: nil,
          cancelled_at: nil,
          created_at: timestamp,
          updated_at: timestamp
        )
        find_by_id_for_owner(user_id: user_id, id: id)
      end

      def find_by_id_for_owner(user_id:, id:)
        conditional_orders.where(user_id: user_id, id: id).first
      end

      def list_for_owner(user_id:)
        conditional_orders.where(user_id: user_id).order(:id).all
      end

      def pending_trigger_candidates(market_id:, last_trade_price:, now: Time.now.utc, limit: DEFAULT_WORK_LIMIT)
        last_trade_price = Money.coerce_decimal(last_trade_price)
        limit = normalize_limit(limit)
        conditional_orders
          .where(market_id: market_id, status: "pending")
          .where { (expires_at =~ nil) | (expires_at > now) }
          .order(:market_id, :trigger_type, :created_at, :id)
          .all
          .select { |order| trigger_satisfied?(order, last_trade_price) }
          .first(limit)
      end

      def lock_pending(id:)
        conditional_orders.where(id: id, status: "pending").for_update.first
      end

      def cancel_for_owner(user_id:, id:)
        transition_status(id: id, from_status: "pending", to_status: "cancelled", user_id: user_id)
      end

      def transition_status(id:, from_status:, to_status:, user_id: nil, triggered_order_id: nil,
                            trigger_idempotency_key: nil)
        from_status = normalize_status(from_status)
        to_status = normalize_status(to_status)
        validate_transition!(from_status, to_status)
        raise ArgumentError, "Triggered order is required" if to_status == "placed" && !triggered_order_id
        raise ArgumentError, "Triggered order is invalid" if to_status != "placed" && triggered_order_id

        timestamp = now
        changes = {
          status: to_status,
          updated_at: timestamp
        }
        changes[:triggered_at] = timestamp if %w[triggered placed].include?(to_status)
        changes[:cancelled_at] = timestamp if to_status == "cancelled"
        changes[:triggered_order_id] = triggered_order_id if triggered_order_id
        changes[:trigger_idempotency_key] = normalize_idempotency_key(trigger_idempotency_key) if trigger_idempotency_key

        scope = conditional_orders.where(id: id, status: from_status)
        scope = scope.where(user_id: user_id) if user_id
        changed = scope.update(changes)
        raise ArgumentError, "Conditional order transition is invalid" if changed != 1

        conditional_orders.where(id: id).first
      end

      private

      attr_reader :database

      def conditional_orders
        database[:conditional_orders]
      end

      def markets
        database[:markets]
      end

      def active_market!(market)
        raise ArgumentError, "Market is invalid" unless market.is_a?(Hash) && market[:id]

        current_market = markets.where(id: market[:id]).first
        raise ArgumentError, "Market is invalid" unless current_market
        raise ArgumentError, "Market is not active" unless current_market[:status] == "active"

        current_market
      end

      def normalize_side(side)
        normalized = side.to_s
        raise ArgumentError, "Conditional order side is invalid" unless SIDES.include?(normalized)

        normalized
      end

      def normalize_trigger_type(trigger_type)
        normalized = trigger_type.to_s
        raise ArgumentError, "Conditional order trigger type is invalid" unless TRIGGER_TYPES.include?(normalized)

        normalized
      end

      def normalize_status(status)
        normalized = status.to_s
        raise ArgumentError, "Conditional order status is invalid" unless STATUSES.include?(normalized)

        normalized
      end

      def validate_transition!(from_status, to_status)
        raise ArgumentError, "Conditional order is terminal" if TERMINAL_STATUSES.include?(from_status)
        return if ALLOWED_TRANSITIONS.fetch(from_status).include?(to_status)

        raise ArgumentError, "Conditional order transition is invalid"
      end

      def trigger_satisfied?(order, last_trade_price)
        return last_trade_price >= order[:trigger_price] if order[:trigger_type] == "last_trade_price_at_or_above"

        last_trade_price <= order[:trigger_price]
      end

      def positive_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless Money.positive?(decimal)

        decimal
      end

      def validate_increment!(value, increment, name)
        return if (value % Money.coerce_decimal(increment)).zero?

        raise ArgumentError, "#{name} is not aligned to market increment"
      end

      def normalize_client_order_id(client_order_id)
        return nil if client_order_id.nil?

        normalized = client_order_id.to_s
        raise ArgumentError, "Client order id is invalid" unless normalized.match?(CLIENT_ORDER_ID_PATTERN)

        normalized
      end

      def optional_note(value)
        return nil if value.nil?

        MarketIntegrityPolicy.optional_client_text(value, field: "Strategy memo", max: MAX_NOTE_LENGTH)
      end

      def optional_future_timestamp(value)
        return nil if value.nil?

        timestamp = coerce_timestamp(value)
        raise ArgumentError, "Conditional order expiry must be in the future" unless timestamp > now

        timestamp
      end

      def coerce_timestamp(value)
        return value.utc if value.is_a?(Time)
        return value.to_time.utc if value.is_a?(DateTime)

        raise ArgumentError, "Conditional order expiry is invalid"
      end

      def normalize_idempotency_key(value)
        text = value.to_s.strip
        raise ArgumentError, "Idempotency key is invalid" unless text.match?(IDEMPOTENCY_KEY_PATTERN)

        text
      end

      def normalize_limit(value)
        text = value.to_s
        raise ArgumentError, "Limit is invalid" unless text.match?(/\A[1-9]\d*\z/)

        limit = Integer(text, 10)
        raise ArgumentError, "Limit is invalid" if limit > MAX_WORK_LIMIT

        limit
      end

      def now
        Time.now.utc
      end
    end
  end
end
