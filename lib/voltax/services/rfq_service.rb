require "date"
require "time"
require "sequel"
require_relative "../account_profiles"
require_relative "../money"
require_relative "../repositories/market_repository"
require_relative "../repositories/rfq_quote_repository"
require_relative "../repositories/rfq_repository"
require_relative "rfq_settlement_service"

module VoltaX
  module Services
    class RFQService
      class InvalidRequest < StandardError; end
      class Forbidden < StandardError; end
      class NotFound < StandardError; end
      class RFQNotOpen < StandardError; end
      class QuoteNotAcceptable < StandardError; end
      class QuoteAlreadyExists < StandardError; end
      class InsufficientFunds < StandardError; end

      def initialize(database:)
        @database = database
      end

      def create(user:, market_symbol:, side:, quantity:, expires_at:, delivery_terms:,
                 target_price: nil, public_comment: nil)
        market = active_market!(market_symbol)
        rfq = rfq_repository.create(
          user_id: user[:id],
          market: market,
          side: side,
          quantity: parse_money(quantity),
          target_price: parse_optional_money(target_price),
          public_comment: public_comment,
          delivery_terms: delivery_terms,
          expires_at: parse_timestamp(expires_at)
        )
        owner_view(rfq)
      rescue ArgumentError
        raise InvalidRequest
      end

      def owner_detail(user:, rfq_id:)
        rfq = rfq_repository.find_by_id_for_owner(user_id: user[:id], id: parse_id(rfq_id))
        raise NotFound unless rfq

        owner_view(rfq)
      rescue ArgumentError
        raise InvalidRequest
      end

      def board
        rfq_repository.list_board
      end

      def quote_workup_for(account:, rfq_id:)
        raise Forbidden unless AccountProfiles.can?(account, "rfq_quote")

        rfq = find_rfq(parse_id(rfq_id))
        raise NotFound unless rfq

        row = QuoteWorkupAssembler.new(service: self, rfq: rfq).packet
        already_quoted = database[:rfq_quotes].where(
          rfq_id: rfq[:id],
          maker_user_id: account[:id],
          status: "submitted"
        ).count.positive?

        row.merge(
          eligible_to_quote: quoteable_by?(rfq: rfq, user: account, already_quoted: already_quoted),
          already_quoted: already_quoted
        )
      rescue ArgumentError
        raise InvalidRequest
      end

      def submit_quote(user:, rfq_id:, price:, quantity:, expires_at: nil)
        raise Forbidden unless AccountProfiles.can?(user, "rfq_quote")

        rfq = find_rfq(parse_id(rfq_id))
        raise NotFound unless rfq

        rfq_quote_repository.create(
          rfq: rfq,
          maker_user: user,
          price: parse_money(price),
          quantity: parse_money(quantity),
          expires_at: expires_at && parse_timestamp(expires_at)
        )
      rescue Sequel::UniqueConstraintViolation
        raise QuoteAlreadyExists
      rescue ArgumentError => error
        map_repository_error(error)
      end

      def accept_quote(user:, rfq_id:, quote_id:)
        id = parse_id(rfq_id)
        rfq = find_rfq(id)
        raise NotFound unless rfq
        raise Forbidden unless rfq[:user_id] == user[:id]

        result = rfq_settlement_service.accept(
          user_id: user[:id],
          rfq_id: id,
          quote_id: parse_id(quote_id)
        )
        [result.fetch(:quote), owner_view(result.fetch(:rfq)), result.fetch(:trade)]
      rescue RFQSettlementService::InsufficientFunds
        raise InsufficientFunds
      rescue RFQSettlementService::Forbidden
        raise Forbidden
      rescue RFQSettlementService::NotFound
        raise NotFound
      rescue RFQSettlementService::QuoteNotAcceptable
        raise QuoteNotAcceptable
      rescue RFQSettlementService::SettlementError
        raise InvalidRequest
      rescue ArgumentError => error
        map_repository_error(error)
      end

      def accepted_counterparty(user:, rfq_id:)
        raise Forbidden unless AccountProfiles.can?(user, "rfq_quote")

        rfq = find_rfq(parse_id(rfq_id))
        raise NotFound unless rfq && %w[accepted settled].include?(rfq[:status]) && rfq[:accepted_quote_id]

        quote = database[:rfq_quotes].where(id: rfq[:accepted_quote_id], maker_user_id: user[:id]).first
        raise NotFound unless quote && quote[:status] == "accepted"

        {
          id: rfq[:id],
          accepted_quote_id: quote[:id],
          market_symbol: market_symbol_for(rfq[:market_id]),
          side: rfq[:side],
          price: quote[:price],
          quantity: quote[:quantity],
          settlement_status: rfq[:status] == "settled" ? "settled" : "pending",
          status: rfq[:status],
          accepted_at: rfq[:updated_at]
        }
      rescue ArgumentError
        raise InvalidRequest
      end

      def simulate_settlement(user:, rfq_id:, quote_id:)
        rfq = find_rfq(parse_id(rfq_id))
        raise NotFound unless rfq

        quote = database[:rfq_quotes].where(rfq_id: rfq[:id], id: parse_id(quote_id)).first
        raise NotFound unless quote
        raise QuoteNotAcceptable unless %w[submitted accepted].include?(quote[:status])
        raise Forbidden unless rfq[:user_id] == user[:id] || quote[:maker_user_id] == user[:id]

        market = market_repository.find_by_id(rfq[:market_id])
        raise InvalidRequest unless market && market[:status] == "active"

        quantity = Money.coerce_decimal(quote[:quantity])
        price = Money.coerce_decimal(quote[:price])
        quote_amount = price * quantity

        {
          rfq_id: rfq[:id],
          quote_id: quote[:id],
          market_symbol: market[:symbol],
          side: rfq[:side],
          price: price,
          quantity: quantity,
          quote_amount: quote_amount,
          participant_legs: settlement_legs(rfq: rfq, market: market, quantity: quantity, quote_amount: quote_amount)
        }
      rescue ArgumentError
        raise InvalidRequest
      end

      private

      attr_reader :database

      def owner_view(rfq)
        [
          rfq,
          market_symbol_for(rfq[:market_id]),
          rfq_quote_repository.list_for_owner(rfq_owner_user_id: rfq[:user_id], rfq_id: rfq[:id])
        ]
      end

      def board_row_for(rfq)
        row = rfq_repository.list_board(market_id: rfq[:market_id], statuses: [rfq[:status]]).find do |candidate|
          candidate[:id] == rfq[:id]
        end
        row || {
          id: rfq[:id],
          market_id: rfq[:market_id],
          market_symbol: market_symbol_for(rfq[:market_id]),
          side: rfq[:side],
          quantity: rfq[:quantity],
          target_price: rfq[:target_price],
          status: rfq[:status],
          public_comment: rfq[:public_comment],
          expires_at: rfq[:expires_at],
          created_at: rfq[:created_at],
          quote_count: database[:rfq_quotes].where(rfq_id: rfq[:id], status: "submitted").count
        }
      end

      def quoteable_by?(rfq:, user:, already_quoted:)
        AccountProfiles.can?(user, "rfq_quote") &&
          rfq[:user_id] != user[:id] &&
          %w[open quoted].include?(rfq[:status]) &&
          coerce_time(rfq[:expires_at]) > Time.now.utc &&
          !already_quoted
      end

      def settlement_legs(rfq:, market:, quantity:, quote_amount:)
        if rfq[:side] == "buy"
          [
            {
              account_profile: "rfq_owner",
              side: "buy",
              debit_asset: market[:quote_asset],
              debit_amount: quote_amount,
              credit_asset: market[:base_asset],
              credit_amount: quantity
            },
            {
              account_profile: "liquidity",
              side: "sell",
              debit_asset: market[:base_asset],
              debit_amount: quantity,
              credit_asset: market[:quote_asset],
              credit_amount: quote_amount
            }
          ]
        else
          [
            {
              account_profile: "rfq_owner",
              side: "sell",
              debit_asset: market[:base_asset],
              debit_amount: quantity,
              credit_asset: market[:quote_asset],
              credit_amount: quote_amount
            },
            {
              account_profile: "liquidity",
              side: "buy",
              debit_asset: market[:quote_asset],
              debit_amount: quote_amount,
              credit_asset: market[:base_asset],
              credit_amount: quantity
            }
          ]
        end
      end

      def active_market!(symbol)
        market = market_repository.find_by_symbol(symbol.to_s)
        raise InvalidRequest unless market && market[:status] == "active"

        market
      end

      def find_rfq(id)
        database[:rfqs].where(id: id).first
      end

      def market_symbol_for(market_id)
        market_repository.find_by_id(market_id).fetch(:symbol)
      end

      def parse_id(value)
        text = value.to_s
        raise ArgumentError unless text.match?(/\A[1-9]\d*\z/)

        Integer(text, 10)
      end

      def parse_money(value)
        Money.parse(value)
      rescue ArgumentError
        raise InvalidRequest
      end

      def parse_optional_money(value)
        value.nil? ? nil : parse_money(value)
      end

      def parse_timestamp(value)
        raise InvalidRequest unless value.is_a?(String)

        Time.iso8601(value).utc
      rescue ArgumentError
        raise InvalidRequest
      end

      def coerce_time(value)
        return value.utc if value.is_a?(Time)
        return value.to_time.utc if value.is_a?(DateTime)

        raise ArgumentError
      end

      def map_repository_error(error)
        case error.message
        when "RFQ owner cannot quote own RFQ", "User is not allowed to quote RFQs", "RFQ not found for owner"
          raise Forbidden
        when "RFQ not open for quotes", "RFQ expired"
          raise RFQNotOpen
        when "Quote not acceptable", "Quote expired"
          raise QuoteNotAcceptable
        else
          raise InvalidRequest
        end
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def rfq_repository
        @rfq_repository ||= Repositories::RFQRepository.new(database: database)
      end

      def rfq_quote_repository
        @rfq_quote_repository ||= Repositories::RFQQuoteRepository.new(database: database)
      end

      def rfq_settlement_service
        @rfq_settlement_service ||= RFQSettlementService.new(database: database)
      end

      class QuoteWorkupAssembler
        def initialize(service:, rfq:)
          @service = service
          @rfq = rfq
        end

        def packet
          base_row.merge(
            pricing_details: pricing_details,
            workup_terms: term_sheet.fetch(:terms)
          )
        end

        private

        attr_reader :service, :rfq

        def base_row
          service.send(:board_row_for, rfq)
        end

        def pricing_details
          {
            pricing_mode: "firm",
            settlement_window: "same-day",
            venue: "central-otc"
          }
        end

        def term_sheet
          {
            terms: rfq[:delivery_terms]
          }
        end
      end
    end
  end
end
