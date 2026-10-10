require "time"
require_relative "../money"

module VoltaX
  module DTOs
    module Helpers
      module_function

      def money(value)
        Money.format(value)
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
