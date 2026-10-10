require "date"
require_relative "../account_profiles"
require_relative "../market_integrity_policy"

module VoltaX
  module Repositories
    class BrokerCampaignRepository
      STATUSES = %w[active paused closed cancelled].freeze
      TERMINAL_STATUSES = %w[closed cancelled].freeze
      ALLOWED_TRANSITIONS = {
        "active" => %w[paused closed cancelled],
        "paused" => %w[active closed cancelled],
        "closed" => [],
        "cancelled" => []
      }.freeze
      CAMPAIGN_CODE_PATTERN = /\A[a-zA-Z0-9_.:-]{3,64}\z/.freeze

      def initialize(database:)
        @database = database
      end

      def create(broker_user:, campaign_code:, name:, status: "active", starts_at: nil, ends_at: nil)
        validate_broker!(broker_user)
        status = normalize_status(status)
        raise ArgumentError, "Campaign status is invalid for creation" unless status == "active"

        campaign_code = normalize_campaign_code(campaign_code)
        name = required_string(name, "Campaign name", MarketIntegrityPolicy::SHORT_CLIENT_TEXT_LIMIT)
        starts_at = optional_timestamp(starts_at, "Campaign start")
        ends_at = optional_timestamp(ends_at, "Campaign end")
        validate_time_window!(starts_at, ends_at)
        timestamp = now

        id = campaigns.insert(
          broker_user_id: broker_user[:id],
          campaign_code: campaign_code,
          name: name,
          status: status,
          starts_at: starts_at,
          ends_at: ends_at,
          created_at: timestamp,
          updated_at: timestamp
        )
        find_by_id_for_broker(broker_user_id: broker_user[:id], id: id)
      end

      def find_by_id_for_broker(broker_user_id:, id:)
        campaigns.where(broker_user_id: broker_user_id, id: id).first
      end

      def find_by_code(campaign_code)
        campaigns.where(campaign_code: normalize_campaign_code(campaign_code)).first
      end

      def list_for_broker(broker_user_id:)
        campaigns.where(broker_user_id: broker_user_id).order(:id).all
      end

      def update_status_for_broker(broker_user_id:, id:, status:)
        status = normalize_status(status)

        database.transaction do
          campaign = campaigns.where(broker_user_id: broker_user_id, id: id).for_update.first
          raise ArgumentError, "Campaign not found for partner" unless campaign
          raise ArgumentError, "Campaign status transition is invalid" unless ALLOWED_TRANSITIONS.fetch(campaign[:status]).include?(status)

          campaigns.where(id: campaign[:id]).update(status: status, updated_at: now)
          campaigns.where(id: campaign[:id]).first
        end
      end

      private

      attr_reader :database

      def campaigns
        database[:broker_campaigns]
      end

      def users
        database[:users]
      end

      def validate_broker!(broker_user)
        raise ArgumentError, "Partner account is invalid" unless broker_user.is_a?(Hash) && broker_user[:id]

        current_user = users.where(id: broker_user[:id]).first
        raise ArgumentError, "Partner account is invalid" unless current_user
        raise ArgumentError, "Partner account is not active" unless current_user[:status] == "active"
        raise ArgumentError, "User is not allowed to own partner campaigns" unless AccountProfiles.can?(current_user, "broker_campaigns")
      end

      def normalize_status(status)
        normalized = status.to_s
        raise ArgumentError, "Campaign status is invalid" unless STATUSES.include?(normalized)

        normalized
      end

      def normalize_campaign_code(campaign_code)
        normalized = campaign_code.to_s.strip
        raise ArgumentError, "Campaign code is invalid" unless normalized.match?(CAMPAIGN_CODE_PATTERN)

        normalized
      end

      def required_string(value, name, max)
        MarketIntegrityPolicy.required_client_text(value, field: name, max: max)
      end

      def optional_timestamp(value, name)
        return nil if value.nil?
        return value.utc if value.is_a?(Time)
        return value.to_time.utc if value.is_a?(DateTime)

        raise ArgumentError, "#{name} is invalid"
      end

      def validate_time_window!(starts_at, ends_at)
        return unless starts_at && ends_at
        return if starts_at < ends_at

        raise ArgumentError, "Campaign time window is invalid"
      end

      def now
        Time.now.utc
      end
    end
  end
end
