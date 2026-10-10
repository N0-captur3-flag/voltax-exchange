require "time"
require_relative "../money"

module VoltaX
  module Presenters
    module LedgerPresenter
      module_function

      def render(entry)
        {
          asset: entry[:asset],
          balance_bucket: entry[:balance_bucket],
          amount: Money.format(entry[:amount]),
          entry_type: entry[:entry_type],
          reference_type: entry[:reference_type],
          reference_id: entry[:reference_id],
          created_at: iso8601(entry[:created_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
