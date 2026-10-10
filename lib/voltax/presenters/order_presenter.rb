require_relative "../dtos/account_order_dto"
require_relative "../dtos/order_reference_dto"

module VoltaX
  module Presenters
    module OrderPresenter
      module_function

      def render(order, market_symbol:)
        DTOs::AccountOrderDTO.render(order, market_symbol: market_symbol)
      end

      def render_reference(order, market_symbol:)
        DTOs::OrderReferenceDTO.render(order, market_symbol: market_symbol)
      end

      def render_book(market_symbol:, bids:, asks:)
        DTOs::AccountOrderDTO.book(market_symbol: market_symbol, bids: bids, asks: asks)
      end

      def render_level(level)
        DTOs::AccountOrderDTO.level(level)
      end
    end
  end
end
