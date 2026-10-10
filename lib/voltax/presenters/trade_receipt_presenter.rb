require_relative "../dtos/account_booking_dto"

module VoltaX
  module Presenters
    module TradeReceiptPresenter
      module_function

      def render(receipt)
        DTOs::AccountBookingDTO.receipt(receipt)
      end
    end
  end
end
