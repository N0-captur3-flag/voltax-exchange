require "time"
require "sequel"
require_relative "../account_profiles"
require_relative "../market_integrity_policy"
require_relative "../repositories/broker_attribution_repository"
require_relative "../repositories/broker_campaign_repository"

module VoltaX
  module Services
    class BrokerService
      class InvalidRequest < StandardError; end
      class Forbidden < StandardError; end
      class NotFound < StandardError; end
      class CampaignCodeTaken < StandardError; end
      class AttributionAlreadyExists < StandardError; end
      class CampaignNotActive < StandardError; end

      FORBIDDEN_ATTRIBUTION_KEYS = MarketIntegrityPolicy::BROKER_ASSIGNMENT_KEYS

      def initialize(database:)
        @database = database
      end

      def create_campaign(user:, campaign_code:, name:, starts_at: nil, ends_at: nil)
        raise Forbidden unless AccountProfiles.can?(user, "broker_campaigns")

        campaign_repository.create(
          broker_user: user,
          campaign_code: campaign_code,
          name: name,
          starts_at: parse_optional_timestamp(starts_at),
          ends_at: parse_optional_timestamp(ends_at)
        )
      rescue Sequel::UniqueConstraintViolation
        raise CampaignCodeTaken
      rescue ArgumentError => error
        map_campaign_error(error)
      end

      def list_campaigns(user:)
        raise Forbidden unless AccountProfiles.can?(user, "broker_campaigns")

        campaign_repository.list_for_broker(broker_user_id: user[:id])
      end

      def create_attribution(user:, payload:)
        ensure_safe_attribution_payload!(payload)

        attribution = attribution_repository.create_for_trader(
          trader_user: user,
          campaign_code: payload["campaign_code"],
          user_reference: payload["user_reference"]
        )
        campaign = campaign_repository.find_by_id_for_broker(
          broker_user_id: attribution[:broker_user_id],
          id: attribution[:campaign_id]
        )
        [attribution, campaign]
      rescue Sequel::UniqueConstraintViolation
        raise AttributionAlreadyExists
      rescue ArgumentError => error
        map_attribution_error(error)
      end

      private

      attr_reader :database

      def ensure_safe_attribution_payload!(payload)
        MarketIntegrityPolicy.ensure_assignment_payload!(payload, blocked_keys: FORBIDDEN_ATTRIBUTION_KEYS)
        raise InvalidRequest unless payload.key?("campaign_code")
      rescue ArgumentError
        raise InvalidRequest
      end

      def parse_optional_timestamp(value)
        return nil if value.nil?
        raise InvalidRequest unless value.is_a?(String)

        Time.iso8601(value).utc
      rescue ArgumentError
        raise InvalidRequest
      end

      def map_campaign_error(error)
        case error.message
        when "User is not allowed to own partner campaigns", "Partner account is not active"
          raise Forbidden
        else
          raise InvalidRequest
        end
      end

      def map_attribution_error(error)
        case error.message
        when "Campaign is invalid"
          raise NotFound
        when "Campaign is not active"
          raise CampaignNotActive
        else
          raise InvalidRequest
        end
      end

      def campaign_repository
        @campaign_repository ||= Repositories::BrokerCampaignRepository.new(database: database)
      end

      def attribution_repository
        @attribution_repository ||= Repositories::BrokerAttributionRepository.new(database: database)
      end
    end
  end
end
