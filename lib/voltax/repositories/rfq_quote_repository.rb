require "date"

require_relative "../account_profiles"
require_relative "../money"

module VoltaX
  module Repositories
    class RFQQuoteRepository
      QUOTE_STATUSES = %w[submitted accepted rejected withdrawn expired].freeze
      OPEN_RFQ_STATUSES = %w[open quoted].freeze

      def initialize(database:)
        @database = database
      end

      def create(rfq:, maker_user:, price:, quantity:, expires_at: nil)
        validate_liquidity_account!(maker_user)
        raise ArgumentError, "RFQ is invalid" unless rfq.is_a?(Hash) && rfq[:id]

        database.transaction do
          current_rfq = rfqs.where(id: rfq[:id]).for_update.first
          validate_rfq_open!(current_rfq)
          raise ArgumentError, "RFQ owner cannot quote own RFQ" if current_rfq[:user_id] == maker_user[:id]

          market = market_for(current_rfq)
          price = positive_decimal(price, "Quote price")
          quantity = positive_decimal(quantity, "Quote quantity")
          validate_increment!(price, market[:tick_size], "Quote price")
          validate_increment!(quantity, market[:lot_size], "Quote quantity")
          unless quantity == Money.coerce_decimal(current_rfq[:quantity])
            raise ArgumentError, "Quote quantity must match RFQ quantity"
          end

          timestamp = now
          rfq_expires_at = coerce_timestamp(current_rfq[:expires_at], "RFQ expiry")
          quote_expires_at = expires_at ? future_timestamp(expires_at, "Quote expiry") : rfq_expires_at
          if quote_expires_at > rfq_expires_at
            raise ArgumentError, "Quote expiry must not exceed RFQ expiry"
          end

          id = rfq_quotes.insert(
            rfq_id: current_rfq[:id],
            maker_user_id: maker_user[:id],
            price: price,
            quantity: quantity,
            status: "submitted",
            expires_at: quote_expires_at,
            created_at: timestamp,
            updated_at: timestamp,
            cancelled_at: nil
          )
          rfqs.where(id: current_rfq[:id], status: "open").update(status: "quoted", updated_at: timestamp)
          find_by_id_for_maker(maker_user_id: maker_user[:id], id: id)
        end
      end

      def find_by_id_for_maker(maker_user_id:, id:)
        rfq_quotes.where(maker_user_id: maker_user_id, id: id).first
      end

      def list_for_maker(maker_user_id:)
        rfq_quotes.where(maker_user_id: maker_user_id).order(:id).all
      end

      def list_for_owner(rfq_owner_user_id:, rfq_id:)
        rfq = rfqs.where(user_id: rfq_owner_user_id, id: rfq_id).first
        raise ArgumentError, "RFQ not found for owner" unless rfq

        rfq_quotes.where(rfq_id: rfq_id).order(:id).all
      end

      def accept_for_owner(rfq_owner_user_id:, rfq_id:, quote_id:)
        database.transaction do
          rfq = rfqs.where(id: rfq_id).for_update.first
          raise ArgumentError, "RFQ not found for owner" unless rfq && rfq[:user_id] == rfq_owner_user_id
          validate_rfq_open!(rfq)

          quote = rfq_quotes.where(rfq_id: rfq_id, id: quote_id).for_update.first
          raise ArgumentError, "Quote not acceptable" unless quote && quote[:status] == "submitted"
          raise ArgumentError, "Quote expired" unless coerce_timestamp(quote[:expires_at], "Quote expiry") > now

          timestamp = now
          rfq_quotes.where(id: quote_id).update(status: "accepted", updated_at: timestamp)
          rfq_quotes.where(rfq_id: rfq_id, status: "submitted").exclude(id: quote_id).update(
            status: "rejected",
            updated_at: timestamp
          )
          rfqs.where(id: rfq_id).update(
            status: "accepted",
            accepted_quote_id: quote_id,
            updated_at: timestamp
          )

          rfq_quotes.where(id: quote_id).first
        end
      end

      def withdraw_for_maker(maker_user_id:, id:)
        timestamp = now
        changed = rfq_quotes.where(maker_user_id: maker_user_id, id: id, status: "submitted").update(
          status: "withdrawn",
          cancelled_at: timestamp,
          updated_at: timestamp
        )
        raise ArgumentError, "Quote not withdrawable" if changed != 1

        find_by_id_for_maker(maker_user_id: maker_user_id, id: id)
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

      def market_for(rfq)
        market = markets.where(id: rfq[:market_id]).first
        raise ArgumentError, "Market is invalid" unless market && market[:status] == "active"

        market
      end

      def validate_rfq_open!(rfq)
        raise ArgumentError, "RFQ is invalid" unless rfq.is_a?(Hash) && rfq[:id]
        raise ArgumentError, "RFQ not open for quotes" unless OPEN_RFQ_STATUSES.include?(rfq[:status])
        raise ArgumentError, "RFQ expired" unless coerce_timestamp(rfq[:expires_at], "RFQ expiry") > now
      end

      def validate_liquidity_account!(maker_user)
        raise ArgumentError, "Liquidity account is invalid" unless maker_user.is_a?(Hash) && maker_user[:id]
        raise ArgumentError, "User is not allowed to quote RFQs" unless AccountProfiles.can?(maker_user, "rfq_quote")
      end

      def positive_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless Money.positive?(decimal)

        decimal
      end

      def validate_increment!(value, increment, name)
        increment = Money.coerce_decimal(increment)
        return if (value % increment).zero?

        raise ArgumentError, "#{name} is not aligned to market increment"
      end

      def future_timestamp(value, name)
        timestamp = coerce_timestamp(value, name)
        raise ArgumentError, "#{name} must be in the future" unless timestamp > now

        timestamp
      end

      def coerce_timestamp(value, name)
        return value.utc if value.is_a?(Time)
        return value.to_time.utc if value.is_a?(DateTime)

        raise ArgumentError, "#{name} is invalid"
      end

      def now
        Time.now.utc
      end
    end
  end
end
