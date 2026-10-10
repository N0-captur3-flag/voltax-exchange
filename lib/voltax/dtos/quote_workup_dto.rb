require_relative "helpers"

module VoltaX
  module DTOs
    module QuoteWorkupDTO
      module_function

      def render(workup)
        rendered = {
          id: workup[:id],
          market_symbol: workup[:market_symbol],
          side: workup[:side],
          quantity: Helpers.money(workup[:quantity]),
          target_price: Helpers.optional_money(workup[:target_price]),
          status: workup[:status],
          public_comment: workup[:public_comment],
          quote_count: workup[:quote_count],
          eligible_to_quote: workup[:eligible_to_quote],
          already_quoted: workup[:already_quoted],
          quote_requirements: {
            account_profile: "liquidity",
            quantity: Helpers.money(workup[:quantity])
          },
          expires_at: Helpers.iso8601(workup[:expires_at]),
          created_at: Helpers.iso8601(workup[:created_at])
        }
        rendered[:workup_terms] = workup[:workup_terms] if workup.key?(:workup_terms)
        rendered
      end
    end
  end
end
