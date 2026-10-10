require_relative "../dtos/public_market_dto"

module VoltaX
  module Presenters
    module MarketPresenter
      module_function

      def render(market)
        DTOs::PublicMarketDTO.render(market)
      end
    end
  end
end
