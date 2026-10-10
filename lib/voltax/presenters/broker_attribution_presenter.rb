require "time"

module VoltaX
  module Presenters
    module BrokerAttributionPresenter
      module_function

      def render(attribution, campaign:)
        {
          id: attribution[:id],
          campaign_id: attribution[:campaign_id],
          campaign_code: campaign[:campaign_code],
          campaign_name: campaign[:name],
          status: attribution[:status],
          source: attribution[:source],
          user_reference: attribution[:user_reference],
          attributed_at: iso8601(attribution[:attributed_at]),
          revoked_at: iso8601(attribution[:revoked_at]),
          created_at: iso8601(attribution[:created_at]),
          updated_at: iso8601(attribution[:updated_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
