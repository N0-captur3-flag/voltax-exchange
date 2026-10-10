require "date"
require_relative "../market_integrity_policy"
require_relative "broker_campaign_repository"

module VoltaX
  module Repositories
    class BrokerAttributionRepository
      SOURCES = %w[self_service].freeze
      STATUSES = %w[active revoked].freeze
      PUBLIC_ACCOUNT_PROFILES = %w[spot liquidity partner].freeze

      def initialize(database:)
        @database = database
      end

      def create_for_trader(trader_user:, campaign_code:, source: "self_service", user_reference: nil)
        validate_trader!(trader_user)
        source = normalize_source(source)

        database.transaction do
          campaign = campaigns.where(campaign_code: normalize_campaign_code(campaign_code)).for_update.first
          validate_active_campaign!(campaign)

          timestamp = now
          id = attributions.insert(
            campaign_id: campaign[:id],
            broker_user_id: campaign[:broker_user_id],
            trader_user_id: trader_user[:id],
            source: source,
            status: "active",
            user_reference: optional_client_text(user_reference, "User reference"),
            attributed_at: timestamp,
            revoked_at: nil,
            created_at: timestamp,
            updated_at: timestamp
          )
          find_for_trader(trader_user_id: trader_user[:id], campaign_id: campaign[:id])
        end
      end

      def find_for_trader(trader_user_id:, campaign_id:)
        attributions.where(trader_user_id: trader_user_id, campaign_id: campaign_id).first
      end

      def list_for_trader(trader_user_id:)
        attributions.where(trader_user_id: trader_user_id).order(:id).all
      end

      def list_for_broker(broker_user_id:)
        attributions.where(broker_user_id: broker_user_id).order(:id).all
      end

      def revoke_for_trader(trader_user_id:, campaign_id:)
        timestamp = now
        changed = attributions.where(trader_user_id: trader_user_id, campaign_id: campaign_id, status: "active").update(
          status: "revoked",
          revoked_at: timestamp,
          updated_at: timestamp
        )
        raise ArgumentError, "Attribution not revocable" if changed != 1

        find_for_trader(trader_user_id: trader_user_id, campaign_id: campaign_id)
      end

      private

      attr_reader :database

      def campaigns
        database[:broker_campaigns]
      end

      def attributions
        database[:broker_attributions]
      end

      def users
        database[:users]
      end

      def validate_trader!(trader_user)
        raise ArgumentError, "Account user is invalid" unless trader_user.is_a?(Hash) && trader_user[:id]

        current_user = users.where(id: trader_user[:id]).first
        raise ArgumentError, "Account user is invalid" unless current_user
        raise ArgumentError, "Account user is not active" unless current_user[:status] == "active"
        unless PUBLIC_ACCOUNT_PROFILES.include?(current_user[:account_profile])
          raise ArgumentError, "Account profile is invalid"
        end
      end

      def validate_active_campaign!(campaign)
        raise ArgumentError, "Campaign is invalid" unless campaign
        raise ArgumentError, "Campaign is not active" unless campaign[:status] == "active"
      end

      def normalize_campaign_code(campaign_code)
        normalized = campaign_code.to_s.strip
        raise ArgumentError, "Campaign code is invalid" unless normalized.match?(BrokerCampaignRepository::CAMPAIGN_CODE_PATTERN)

        normalized
      end

      def normalize_source(source)
        normalized = source.to_s
        raise ArgumentError, "Attribution source is invalid" unless SOURCES.include?(normalized)

        normalized
      end

      def optional_client_text(value, field)
        MarketIntegrityPolicy.optional_client_text(value, field: field, max: MarketIntegrityPolicy::BOARD_COMMENT_LIMIT)
      end

      def now
        Time.now.utc
      end
    end
  end
end
