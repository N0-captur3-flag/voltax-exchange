require_relative "helpers"

module VoltaX
  module DTOs
    module PublicMarketDTO
      module_function

      def render(market)
        {
          symbol: market[:symbol],
          base_asset: market[:base_asset],
          quote_asset: market[:quote_asset],
          tick_size: market[:tick_size].to_s("F"),
          lot_size: market[:lot_size].to_s("F"),
          status: market[:status]
        }
      end
    end
  end
end
