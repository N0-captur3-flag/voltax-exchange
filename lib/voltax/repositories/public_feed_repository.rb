require "json"
require_relative "../money"
require_relative "../market_integrity_policy"

module VoltaX
  module Repositories
    class PublicFeedRepository
      EVENT_TYPES = %w[
        trade_executed
        order_book_updated
        rfq_settled
        broker_report_period_closed
        market_signal_activated
        conditional_order_expired
        market_tick
      ].freeze
      EVENT_PAYLOAD_FIELDS = {
        "trade_executed" => %w[
          trade_id
          side
          origin
          quote_amount
        ],
        "order_book_updated" => %w[
          order_book_changed
          reason
        ],
        "rfq_settled" => %w[
          trade_id
          side
          origin
          quote_amount
        ],
        "broker_report_period_closed" => %w[
          time_bucket
          status
        ],
        "market_signal_activated" => %w[
          conditional_order_id
          side
          trigger_type
          trigger_price
          limit_price
          status
          activation_context
        ],
        "conditional_order_expired" => %w[
          side
          trigger_type
          status
        ],
        "market_tick" => %w[
          reason
        ]
      }.freeze
      MAX_PAYLOAD_DEPTH = 4
      MAX_PAYLOAD_KEYS = 24
      MAX_METADATA_KEYS = 16
      MAX_KEY_LENGTH = 64
      MAX_STRING_LENGTH = 512
      MAX_PAYLOAD_BYTES = 4096
      DEFAULT_LIMIT = 100
      MAX_LIMIT = 500

      def initialize(database:)
        @database = database
      end

      def append(event_type:, market_symbol:, price: nil, quantity: nil, public_reason: nil, payload: {}, idempotency_key: nil,
                 reference_type: nil, reference_id: nil)
        event_type = normalize_event_type(event_type)
        market = find_market!(market_symbol)
        price = optional_money(price, "Price")
        quantity = optional_money(quantity, "Quantity")
        public_reason = optional_public_reason(public_reason)
        payload = normalize_payload(event_type, payload)
        idempotency_key = optional_idempotency_key(idempotency_key)
        reference_type = optional_reference(reference_type, "Reference type")
        reference_id = optional_reference(reference_id, "Reference id")

        database.transaction do
          existing = find_by_idempotency_key(idempotency_key) if idempotency_key
          return existing if existing

          id = events.insert(
            event_type: event_type,
            market_id: market[:id],
            market_symbol: market[:symbol],
            price: price,
            quantity: quantity,
            public_reason: public_reason,
            payload_json: JSON.generate(payload),
            idempotency_key: idempotency_key,
            reference_type: reference_type,
            reference_id: reference_id,
            created_at: now
          )
          events.where(id: id).first
        end
      rescue Sequel::UniqueConstraintViolation
        raise unless idempotency_key

        find_by_idempotency_key(idempotency_key)
      end

      def list(market_symbol: nil, since_sequence: 0, limit: DEFAULT_LIMIT)
        dataset = events
        dataset = dataset.where(market_symbol: normalize_market_symbol(market_symbol)) if market_symbol
        since_sequence = normalize_since_sequence(since_sequence)
        limit = normalize_limit(limit)
        dataset
          .where { sequence > since_sequence }
          .order(:sequence)
          .limit(limit)
          .all
      end

      def list_feed_events(reason:, market_symbol: nil, since_sequence: 0, limit: DEFAULT_LIMIT)
        reason = optional_public_reason(reason)
        since_sequence = normalize_since_sequence(since_sequence)
        limit = normalize_limit(limit)
        dataset = events.where(public_reason: reason)
        dataset = dataset.where(market_symbol: normalize_market_symbol(market_symbol)) if market_symbol
        dataset
          .where { sequence > since_sequence }
          .order(:sequence)
          .limit(limit)
          .all
      end

      def find_public_feed_event(sequence)
        events.where(sequence: normalize_since_sequence(sequence)).first
      end

      def find_market_snapshot(sequence)
        events.where(sequence: normalize_since_sequence(sequence), event_type: "market_tick").first
      end

      def tail_sequence(market_symbol: nil)
        dataset = events
        dataset = dataset.where(market_symbol: normalize_market_symbol(market_symbol)) if market_symbol
        dataset.max(:sequence).to_i
      end

      def find_by_idempotency_key(idempotency_key)
        return nil unless idempotency_key

        events.where(idempotency_key: idempotency_key).first
      end

      private

      attr_reader :database

      def events
        database[:public_feed_events]
      end

      def markets
        database[:markets]
      end

      def find_market!(market_symbol)
        market = markets.where(symbol: normalize_market_symbol(market_symbol)).first
        raise ArgumentError, "Market is invalid" unless market
        raise ArgumentError, "Market is not active" unless market[:status] == "active"

        market
      end

      def normalize_event_type(event_type)
        text = event_type.to_s
        raise ArgumentError, "Feed event type is invalid" unless EVENT_TYPES.include?(text)

        text
      end

      def normalize_market_symbol(market_symbol)
        text = market_symbol.to_s.strip
        raise ArgumentError, "Market symbol is invalid" if text.empty?

        text
      end

      def optional_money(value, name)
        return nil if value.nil?

        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless decimal.positive?

        decimal
      end

      def optional_public_reason(value)
        return nil if value.nil?

        text = value.to_s.strip
        raise ArgumentError, "Public reason is invalid" if text.empty? || text.length > 128
        reject_reserved_text!(text)

        text
      end

      def normalize_payload(event_type, payload)
        raise ArgumentError, "Feed payload is invalid" unless payload.is_a?(Hash)
        raise ArgumentError, "Feed payload is invalid" if payload.length > MAX_PAYLOAD_KEYS

        allowed_fields = EVENT_PAYLOAD_FIELDS.fetch(event_type)
        normalized = payload.each_with_object({}) do |(key, value), memo|
          key_text = key.to_s
          validate_payload_key!(key_text)
          raise ArgumentError, "Feed payload key is not allowed" unless allowed_fields.include?(key_text)

          memo[key_text] = normalize_payload_value(value, depth: 1)
        end
        raise ArgumentError, "Feed payload is invalid" if JSON.generate(normalized).bytesize > MAX_PAYLOAD_BYTES

        normalized
      end

      def normalize_payload_value(value, depth:)
        raise ArgumentError, "Feed payload value is invalid" if depth > MAX_PAYLOAD_DEPTH

        case value
        when Hash
          normalize_metadata(value, depth: depth + 1)
        when String
          raise ArgumentError, "Feed payload value is invalid" if value.length > MAX_STRING_LENGTH
          reject_reserved_text!(value)
          value
        when Integer, TrueClass, FalseClass, NilClass
          value
        when BigDecimal
          Money.format(value)
        else
          raise ArgumentError, "Feed payload value is invalid"
        end
      end

      def normalize_metadata(value, depth:)
        raise ArgumentError, "Feed payload value is invalid" if value.length > MAX_METADATA_KEYS

        value.each_with_object({}) do |(key, metadata_value), normalized|
          key_text = key.to_s
          validate_payload_key!(key_text)
          normalized[key_text] = normalize_payload_value(metadata_value, depth: depth)
        end
      end

      def validate_payload_key!(text)
        raise ArgumentError, "Feed payload key is invalid" if text.empty? || text.length > MAX_KEY_LENGTH

        reject_reserved_text!(text)
      end

      def reject_reserved_text!(text)
        MarketIntegrityPolicy.ensure_public_event_text!(text)
      rescue ArgumentError
        raise ArgumentError, "Feed payload contains invalid data"
      end

      def optional_idempotency_key(value)
        return nil if value.nil?

        text = value.to_s.strip
        raise ArgumentError, "Idempotency key is invalid" unless text.match?(/\A[a-zA-Z0-9_.:-]{8,128}\z/)

        text
      end

      def optional_reference(value, name)
        return nil if value.nil?

        text = value.to_s.strip
        raise ArgumentError, "#{name} is invalid" if text.empty? || text.length > 128
        reject_reserved_text!(text)

        text
      end

      def normalize_since_sequence(value)
        text = value.to_s
        raise ArgumentError, "Since sequence is invalid" unless text.match?(/\A\d+\z/)

        Integer(text, 10)
      end

      def normalize_limit(value)
        text = value.to_s
        raise ArgumentError, "Limit is invalid" unless text.match?(/\A[1-9]\d*\z/)

        limit = Integer(text, 10)
        raise ArgumentError, "Limit is invalid" if limit > MAX_LIMIT

        limit
      end

      def now
        Time.now.utc
      end
    end
  end
end
