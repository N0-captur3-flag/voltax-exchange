require "time"
require_relative "../money"

module VoltaX
  module Presenters
    module RFQQuotePresenter
      module_function

      def render_owner(quote)
        {
          id: quote[:id],
          price: Money.format(quote[:price]),
          quantity: Money.format(quote[:quantity]),
          status: quote[:status],
          expires_at: iso8601(quote[:expires_at]),
          created_at: iso8601(quote[:created_at]),
          updated_at: iso8601(quote[:updated_at]),
          cancelled_at: iso8601(quote[:cancelled_at])
        }
      end

      def render_maker(quote)
        {
          id: quote[:id],
          rfq_id: quote[:rfq_id],
          price: Money.format(quote[:price]),
          quantity: Money.format(quote[:quantity]),
          status: quote[:status],
          expires_at: iso8601(quote[:expires_at]),
          created_at: iso8601(quote[:created_at]),
          updated_at: iso8601(quote[:updated_at]),
          cancelled_at: iso8601(quote[:cancelled_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
