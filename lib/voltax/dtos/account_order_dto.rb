require_relative "helpers"

module VoltaX
  module DTOs
    module AccountOrderDTO
      module_function

      def render(order, market_symbol:)
        {
          id: order[:id],
          market_symbol: market_symbol,
          side: order[:side],
          order_type: order[:order_type],
          status: order[:status],
          limit_price: Helpers.money(order[:limit_price]),
          original_quantity: Helpers.money(order[:original_quantity]),
          filled_quantity: Helpers.money(order[:filled_quantity]),
          remaining_quantity: Helpers.money(order[:remaining_quantity]),
          client_order_id: order[:client_order_id],
          execution_memo: order[:execution_memo],
          created_at: Helpers.iso8601(order[:created_at]),
          updated_at: Helpers.iso8601(order[:updated_at]),
          cancelled_at: Helpers.iso8601(order[:cancelled_at])
        }
      end

      def book(market_symbol:, bids:, asks:)
        {
          market_symbol: market_symbol,
          bids: bids.map { |level| level(level) },
          asks: asks.map { |level| level(level) }
        }
      end

      def level(level)
        {
          price: Helpers.money(level[:price]),
          quantity: Helpers.money(level[:quantity])
        }
      end
    end
  end
end
