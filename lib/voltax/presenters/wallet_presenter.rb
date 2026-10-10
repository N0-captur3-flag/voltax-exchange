require "time"
require_relative "../money"

module VoltaX
  module Presenters
    module WalletPresenter
      module_function

      def render(wallet)
        {
          asset: wallet[:asset],
          available_balance: Money.format(wallet[:available_balance]),
          locked_balance: Money.format(wallet[:locked_balance]),
          updated_at: iso8601(wallet[:updated_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
