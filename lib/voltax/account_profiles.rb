# frozen_string_literal: true

module VoltaX
  module AccountProfiles
    PUBLIC_PROFILES = %w[spot liquidity partner].freeze
    INTERNAL_PROFILES = %w[auditor system_bot].freeze
    ALL_PROFILES = (PUBLIC_PROFILES + INTERNAL_PROFILES).freeze

    INTERNAL_ROLE_BY_PROFILE = {
      "spot" => "trader",
      "liquidity" => "market_maker",
      "partner" => "broker",
      "auditor" => "auditor",
      "system_bot" => "system_bot"
    }.freeze

    CAPABILITIES_BY_PROFILE = {
      "spot" => %w[orders rfq_board broker_attribution],
      "liquidity" => %w[orders rfq_board rfq_quote broker_attribution],
      "partner" => %w[orders rfq_board broker_attribution broker_campaigns broker_reports],
      "auditor" => [],
      "system_bot" => []
    }.transform_values(&:freeze).freeze

    module_function

    def capabilities_for(user_or_profile)
      profile = account_profile(user_or_profile)
      return [] unless profile

      CAPABILITIES_BY_PROFILE.fetch(profile, [])
    end

    def can?(user, capability)
      active_user?(user) && capabilities_for(user).include?(capability.to_s)
    end

    def internal_role_for(user_or_profile)
      INTERNAL_ROLE_BY_PROFILE[account_profile(user_or_profile)]
    end

    def account_profile(user_or_profile)
      return user_or_profile.to_s unless user_or_profile.is_a?(Hash)

      user_or_profile[:account_profile] || user_or_profile["account_profile"]
    end

    def active_user?(user)
      user.is_a?(Hash) && user[:id] && user[:status] == "active"
    end
  end
end
