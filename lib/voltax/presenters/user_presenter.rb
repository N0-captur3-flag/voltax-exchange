require "time"
require_relative "../account_profiles"

module VoltaX
  module Presenters
    module UserPresenter
      module_function

      def render(user)
        {
          id: user[:id],
          username: user[:username],
          account_profile: user[:account_profile],
          capabilities: AccountProfiles.capabilities_for(user),
          status: user[:status],
          created_at: iso8601(user[:created_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
