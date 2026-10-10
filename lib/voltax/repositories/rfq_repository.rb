require "date"
require "sequel"

require_relative "../market_integrity_policy"
require_relative "../money"

module VoltaX
  module Repositories
    class RFQRepository
      SIDES = %w[buy sell].freeze
      STATUSES = %w[open quoted accepted settled cancelled expired].freeze
      BOARD_STATUSES = %w[open quoted].freeze
      PUBLIC_BOARD_FIELDS = %i[
        id market_id market_symbol side quantity target_price status public_comment expires_at created_at quote_count
      ].freeze

      def initialize(database:)
        @database = database
      end

      def create(user_id:, market:, side:, quantity:, expires_at:, delivery_terms:,
                 target_price: nil, public_comment: nil)
        market = active_market!(market)
        side = normalize_side(side)
        quantity = positive_decimal(quantity, "RFQ quantity")
        target_price = optional_positive_decimal(target_price, "RFQ target price")
        validate_increment!(quantity, market[:lot_size], "RFQ quantity")
        validate_increment!(target_price, market[:tick_size], "RFQ target price") if target_price
        expires_at = future_timestamp(expires_at)
        delivery_terms = required_string(delivery_terms, "Delivery terms")
        timestamp = now

        id = rfqs.insert(
          user_id: user_id,
          market_id: market[:id],
          side: side,
          quantity: quantity,
          target_price: target_price,
          status: "open",
          public_comment: optional_string(public_comment, "Public comment", MarketIntegrityPolicy::BOARD_COMMENT_LIMIT),
          delivery_terms: delivery_terms,
          accepted_quote_id: nil,
          expires_at: expires_at,
          created_at: timestamp,
          updated_at: timestamp,
          cancelled_at: nil
        )
        find_by_id_for_owner(user_id: user_id, id: id)
      end

      def find_by_id_for_owner(user_id:, id:)
        rfqs.where(user_id: user_id, id: id).first
      end

      def list_for_owner(user_id:)
        rfqs.where(user_id: user_id).order(:id).all
      end

      def list_board(market_id: nil, statuses: BOARD_STATUSES)
        normalized_statuses = Array(statuses).map { |status| normalize_status(status) }
        dataset = rfqs.where(status: normalized_statuses)
        dataset = dataset.where(market_id: market_id) if market_id

        dataset.order(:expires_at, :id).all.map { |row| board_row(row) }
      end

      def search_public_comments(query, statuses: BOARD_STATUSES)
        text = query.to_s.strip
        raise ArgumentError, "Public comment search is invalid" if text.empty? || text.length > 64
        raise ArgumentError, "Public comment search is invalid" unless text.match?(/\A[a-zA-Z0-9 .:-]+\z/)

        normalized_statuses = Array(statuses).map { |status| normalize_status(status) }
        rfqs
          .where(status: normalized_statuses)
          .where(Sequel.ilike(:public_comment, "%#{text}%"))
          .order(:expires_at, :id)
          .limit(50)
          .all
          .map { |row| board_row(row) }
      end

      def cancel_for_owner(user_id:, id:)
        timestamp = now
        changed = rfqs.where(user_id: user_id, id: id, status: %w[open quoted]).update(
          status: "cancelled",
          cancelled_at: timestamp,
          updated_at: timestamp
        )
        raise ArgumentError, "RFQ not cancellable" if changed != 1

        find_by_id_for_owner(user_id: user_id, id: id)
      end

      def mark_quoted(id:)
        rfqs.where(id: id, status: "open").update(status: "quoted", updated_at: now)
        rfqs.where(id: id).first
      end

      private

      attr_reader :database

      def rfqs
        database[:rfqs]
      end

      def rfq_quotes
        database[:rfq_quotes]
      end

      def markets
        database[:markets]
      end

      def board_row(row)
        market = markets.where(id: row[:market_id]).first
        {
          id: row[:id],
          market_id: row[:market_id],
          market_symbol: market && market[:symbol],
          side: row[:side],
          quantity: row[:quantity],
          target_price: row[:target_price],
          status: row[:status],
          public_comment: row[:public_comment],
          expires_at: row[:expires_at],
          created_at: row[:created_at],
          quote_count: rfq_quotes.where(rfq_id: row[:id], status: "submitted").count
        }.select { |key, _value| PUBLIC_BOARD_FIELDS.include?(key) }
      end

      def normalize_side(side)
        normalized = side.to_s
        raise ArgumentError, "RFQ side is invalid" unless SIDES.include?(normalized)

        normalized
      end

      def normalize_status(status)
        normalized = status.to_s
        raise ArgumentError, "RFQ status is invalid" unless STATUSES.include?(normalized)

        normalized
      end

      def active_market!(market)
        raise ArgumentError, "Market is invalid" unless market.is_a?(Hash) && market[:id]

        current_market = markets.where(id: market[:id]).first
        raise ArgumentError, "Market is invalid" unless current_market
        raise ArgumentError, "Market is not active" unless current_market[:status] == "active"

        current_market
      end

      def positive_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless Money.positive?(decimal)

        decimal
      end

      def optional_positive_decimal(value, name)
        return nil if value.nil?

        positive_decimal(value, name)
      end

      def validate_increment!(value, increment, name)
        increment = Money.coerce_decimal(increment)
        return if (value % increment).zero?

        raise ArgumentError, "#{name} is not aligned to market increment"
      end

      def future_timestamp(value)
        timestamp = coerce_timestamp(value, "RFQ expiry")
        raise ArgumentError, "RFQ expiry must be in the future" unless timestamp > now

        timestamp
      end

      def coerce_timestamp(value, name)
        return value.utc if value.is_a?(Time)
        return value.to_time.utc if value.is_a?(DateTime)

        raise ArgumentError, "#{name} is invalid"
      end

      def required_string(value, name)
        MarketIntegrityPolicy.required_client_text(value, field: name)
      end

      def optional_string(value, name, max)
        MarketIntegrityPolicy.optional_client_text(value, field: name, max: max)
      end

      def now
        Time.now.utc
      end
    end
  end
end
