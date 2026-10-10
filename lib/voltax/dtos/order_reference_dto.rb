require_relative "account_order_dto"

module VoltaX
  module DTOs
    module OrderReferenceDTO
      module_function

      def render(order, market_symbol:)
        AccountOrderDTO.render(order, market_symbol: market_symbol)
      end
    end
  end
end
