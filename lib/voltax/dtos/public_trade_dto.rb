require_relative "helpers"

module VoltaX
  module DTOs
    module PublicTradeDTO
      module_function

      def render(trade, market_symbol:)
        {
          id: trade[:id],
          market_symbol: market_symbol,
          price: Helpers.money(trade[:execution_price]),
          quantity: Helpers.money(trade[:executed_quantity]),
          quote_amount: Helpers.money(trade[:quote_amount]),
          aggressor_side: trade[:aggressor_side],
          created_at: Helpers.iso8601(trade[:created_at])
        }
      end
    end
  end
end
