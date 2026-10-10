require "time"
require_relative "../money"
require_relative "../dtos/quote_workup_dto"
require_relative "../dtos/rfq_board_dto"

module VoltaX
  module Presenters
    module RFQPresenter
      module_function

      def render_owner(rfq, market_symbol:, quotes: [])
        {
          id: rfq[:id],
          market_symbol: market_symbol,
          side: rfq[:side],
          quantity: Money.format(rfq[:quantity]),
          target_price: optional_money(rfq[:target_price]),
          status: rfq[:status],
          public_comment: rfq[:public_comment],
          delivery_terms: rfq[:delivery_terms],
          accepted_quote_id: rfq[:accepted_quote_id],
          expires_at: iso8601(rfq[:expires_at]),
          created_at: iso8601(rfq[:created_at]),
          updated_at: iso8601(rfq[:updated_at]),
          cancelled_at: iso8601(rfq[:cancelled_at]),
          quotes: quotes
        }
      end

      def render_board(row)
        DTOs::RFQBoardDTO.render(row)
      end

      def render_workup(workup)
        DTOs::QuoteWorkupDTO.render(workup)
      end

      def render_accepted_counterparty(view)
        {
          id: view[:id],
          accepted_quote_id: view[:accepted_quote_id],
          market_symbol: view[:market_symbol],
          side: view[:side],
          price: Money.format(view[:price]),
          quantity: Money.format(view[:quantity]),
          settlement_status: view[:settlement_status],
          status: view[:status],
          accepted_at: iso8601(view[:accepted_at])
        }
      end

      def render_settlement_simulation(simulation)
        {
          rfq_id: simulation[:rfq_id],
          quote_id: simulation[:quote_id],
          market_symbol: simulation[:market_symbol],
          side: simulation[:side],
          price: Money.format(simulation[:price]),
          quantity: Money.format(simulation[:quantity]),
          quote_amount: Money.format(simulation[:quote_amount]),
          settlement_status: "simulated",
          mutates_state: false,
          participant_legs: simulation[:participant_legs].map do |leg|
            {
              account_profile: leg[:account_profile],
              side: leg[:side],
              debit_asset: leg[:debit_asset],
              debit_amount: Money.format(leg[:debit_amount]),
              credit_asset: leg[:credit_asset],
              credit_amount: Money.format(leg[:credit_amount])
            }
          end
        }
      end

      def optional_money(value)
        value.nil? ? nil : Money.format(value)
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
