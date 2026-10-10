require_relative "../dtos/account_booking_dto"
require_relative "../dtos/public_trade_dto"
require_relative "../dtos/venue_allocation_dto"

module VoltaX
  module Presenters
    module TradePresenter
      module_function

      def render(trade, market_symbol:)
        DTOs::PublicTradeDTO.render(trade, market_symbol: market_symbol)
      end

      def render_participant_detail(trade, market_symbol:, receipt:, booking_rows: [receipt])
        detail = render(trade, market_symbol: market_symbol).merge(
          account_booking: account_booking(receipt)
        )
        booking_row = booking_rows.find { |row| row[:id] != receipt[:id] }
        return detail unless booking_row

        detail.merge(
          venue_allocation: allocation_notice(booking_row)
        )
      end

      def account_booking(receipt)
        DTOs::AccountBookingDTO.packet(receipt)
      end

      def allocation_notice(receipt)
        DTOs::VenueAllocationDTO.notice(receipt)
      end
    end
  end
end
