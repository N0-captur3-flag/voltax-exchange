require_relative "../dtos/conditional_owner_dto"

module VoltaX
  module Presenters
    module ConditionalOrderPresenter
      module_function

      def render_owner(order, market_symbol:)
        DTOs::ConditionalOwnerDTO.render(order, market_symbol: market_symbol)
      end
    end
  end
end
