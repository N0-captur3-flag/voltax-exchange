require_relative "helpers"

module VoltaX
  module DTOs
    module PublicEventDTO
      module_function

      def render(event, payload:)
        {
          sequence: event[:sequence],
          event_type: event[:event_type],
          market_symbol: event[:market_symbol],
          price: Helpers.optional_money(event[:price]),
          quantity: Helpers.optional_money(event[:quantity]),
          public_reason: event[:public_reason],
          payload: payload,
          created_at: Helpers.iso8601(event[:created_at])
        }
      end
    end
  end
end
