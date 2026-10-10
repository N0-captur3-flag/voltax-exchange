require_relative "../money"

module VoltaX
  module Repositories
    class TradeRepository
      SIDES = %w[buy sell].freeze

      def initialize(database:)
        @database = database
      end

      def create(market_id:, buy_order_id:, sell_order_id:, maker_order_id:, taker_order_id:, execution_price:,
                 executed_quantity:, quote_amount:, aggressor_side:)
        execution_price = positive_decimal(execution_price, "Execution price")
        executed_quantity = positive_decimal(executed_quantity, "Executed quantity")
        quote_amount = positive_decimal(quote_amount, "Quote amount")
        aggressor_side = normalize_side(aggressor_side)

        id = trades.insert(
          market_id: market_id,
          buy_order_id: buy_order_id,
          sell_order_id: sell_order_id,
          maker_order_id: maker_order_id,
          taker_order_id: taker_order_id,
          execution_price: execution_price,
          executed_quantity: executed_quantity,
          quote_amount: quote_amount,
          aggressor_side: aggressor_side,
          created_at: Time.now.utc
        )
        find_by_id(id)
      end

      def find_by_id(id)
        trades.where(id: id).first
      end

      def find_public_trade(id)
        trades.where(id: parse_id(id)).first
      end

      def list_for_market(market_id:)
        trades.where(market_id: market_id).order(:public_sequence).all
      end

      def list_public_trades_for_market(market_id:, limit: 100)
        limit = normalize_limit(limit)
        trades.where(market_id: market_id).order(:public_sequence).limit(limit).all
      end

      private

      attr_reader :database

      def trades
        database[:trades]
      end

      def parse_id(id)
        text = id.to_s
        raise ArgumentError, "Trade id is invalid" unless text.match?(/\A[1-9]\d*\z/)

        Integer(text, 10)
      end

      def normalize_side(side)
        normalized = side.to_s
        raise ArgumentError, "Aggressor side is invalid" unless SIDES.include?(normalized)

        normalized
      end

      def positive_decimal(value, name)
        decimal = Money.coerce_decimal(value)
        raise ArgumentError, "#{name} must be positive" unless Money.positive?(decimal)

        decimal
      end

      def normalize_limit(value)
        text = value.to_s
        raise ArgumentError, "Trade limit is invalid" unless text.match?(/\A[1-9]\d*\z/)

        limit = Integer(text, 10)
        raise ArgumentError, "Trade limit is invalid" if limit > 500

        limit
      end
    end
  end
end
