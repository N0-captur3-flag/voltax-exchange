require_relative "helpers"

module VoltaX
  module DTOs
    module RFQBoardDTO
      module_function

      def render(row)
        {
          id: row[:id],
          market_symbol: row[:market_symbol],
          side: row[:side],
          quantity: Helpers.money(row[:quantity]),
          target_price: Helpers.optional_money(row[:target_price]),
          status: row[:status],
          public_comment: row[:public_comment],
          quote_count: row[:quote_count],
          expires_at: Helpers.iso8601(row[:expires_at]),
          created_at: Helpers.iso8601(row[:created_at])
        }
      end
    end
  end
end
