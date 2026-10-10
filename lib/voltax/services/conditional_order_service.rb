require "time"
require "sequel"

require_relative "../money"
require_relative "../repositories/conditional_order_repository"
require_relative "../repositories/market_repository"

module VoltaX
  module Services
    class ConditionalOrderService
      class InvalidRequest < StandardError; end
      class NotFound < StandardError; end
      class ClientOrderIdTaken < StandardError; end

      def initialize(database:)
        @database = database
      end

      def create(user:, market_symbol:, side:, trigger_type:, trigger_price:, limit_price:, quantity:,
                 client_order_id: nil, signal_context: nil, expires_at: nil)
        market = active_market!(market_symbol)
        order = conditional_order_repository.create(
          user_id: user[:id],
          market: market,
          side: side,
          trigger_type: trigger_type,
          trigger_price: parse_money(trigger_price),
          limit_price: parse_money(limit_price),
          quantity: parse_money(quantity),
          client_order_id: client_order_id,
          signal_context: signal_context,
          expires_at: parse_optional_timestamp(expires_at)
        )

        [order, market[:symbol]]
      rescue Sequel::UniqueConstraintViolation
        raise ClientOrderIdTaken
      rescue ArgumentError
        raise InvalidRequest
      end

      def list_for_owner(user:)
        orders = conditional_order_repository.list_for_owner(user_id: user[:id])
        symbols = market_symbols_for(orders.map { |order| order[:market_id] })
        orders.map { |order| [order, symbols.fetch(order[:market_id])] }
      end

      def owner_detail(user:, conditional_order_id:)
        order = conditional_order_repository.find_by_id_for_owner(
          user_id: user[:id],
          id: parse_id(conditional_order_id)
        )
        raise NotFound unless order

        [order, market_symbol_for(order[:market_id])]
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

      def parse_money(value)
        Money.parse(value)
      rescue ArgumentError
        raise InvalidRequest
      end

      def parse_optional_timestamp(value)
        return nil if value.nil?
        raise InvalidRequest unless value.is_a?(String)

        Time.iso8601(value).utc
      rescue ArgumentError
        raise InvalidRequest
      end

      def parse_id(value)
        text = value.to_s
        raise ArgumentError unless text.match?(/\A[1-9]\d*\z/)

        Integer(text, 10)
      end

      def market_symbol_for(market_id)
        market_repository.find_by_id(market_id).fetch(:symbol)
      end

      def market_symbols_for(market_ids)
        market_ids.uniq.to_h { |id| [id, market_symbol_for(id)] }
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def conditional_order_repository
        @conditional_order_repository ||= Repositories::ConditionalOrderRepository.new(database: database)
      end
    end
  end
end
