require_relative "helpers"

module VoltaX
  module DTOs
    module ConditionalOwnerDTO
      module_function

      def render(order, market_symbol:)
        {
          id: order[:id],
          market_symbol: market_symbol,
          side: order[:side],
          order_type: order[:order_type],
          trigger_type: order[:trigger_type],
          trigger_price: Helpers.money(order[:trigger_price]),
          limit_price: Helpers.money(order[:limit_price]),
          quantity: Helpers.money(order[:quantity]),
          status: order[:status],
          client_order_id: order[:client_order_id],
          signal_context: order[:signal_context],
          expires_at: Helpers.iso8601(order[:expires_at]),
          triggered_at: Helpers.iso8601(order[:triggered_at]),
          cancelled_at: Helpers.iso8601(order[:cancelled_at]),
          created_at: Helpers.iso8601(order[:created_at]),
          updated_at: Helpers.iso8601(order[:updated_at])
        }
      end
    end
  end
end
