require_relative "../dtos/partner_report_row_dto"

module VoltaX
  module Presenters
    module BrokerReportPresenter
      module_function

      def render_trade(row)
        DTOs::PartnerReportRowDTO.trade(row)
      end

      def render_monthly(row)
        DTOs::PartnerReportRowDTO.monthly(row)
      end
    end
  end
end
