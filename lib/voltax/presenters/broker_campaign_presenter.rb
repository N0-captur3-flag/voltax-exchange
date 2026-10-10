require "time"

module VoltaX
  module Presenters
    module BrokerCampaignPresenter
      module_function

      def render(campaign)
        {
          id: campaign[:id],
          campaign_code: campaign[:campaign_code],
          name: campaign[:name],
          status: campaign[:status],
          starts_at: iso8601(campaign[:starts_at]),
          ends_at: iso8601(campaign[:ends_at]),
          created_at: iso8601(campaign[:created_at]),
          updated_at: iso8601(campaign[:updated_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
