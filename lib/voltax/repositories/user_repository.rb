require_relative "../auth/password"
require_relative "../account_profiles"

module VoltaX
  module Repositories
    class UserRepository
      ACCOUNT_PROFILES = AccountProfiles::ALL_PROFILES
      PUBLIC_ACCOUNT_PROFILES = AccountProfiles::PUBLIC_PROFILES
      INTERNAL_ACCOUNT_PROFILES = AccountProfiles::INTERNAL_PROFILES
      STATUSES = %w[active disabled].freeze

      def initialize(database:, environment: ENV.fetch("RACK_ENV", "development"))
        @database = database
        @environment = environment
      end

      def create(username:, password:, account_profile: "spot", status: "active")
        account_profile = normalize_account_profile(account_profile)
        validate_public_account_profile!(account_profile)
        validate_status!(status)

        timestamp = now
        id = users.insert(
          username: username.to_s,
          password_hash: Auth::Password.hash(password, environment: @environment),
          account_profile: account_profile,
          status: status,
          created_at: timestamp,
          updated_at: timestamp
        )
        find_by_id(id)
      end

      def find_by_id(id)
        users.where(id: id).first
      end

      def find_by_username(username)
        users.where(username: username.to_s).first
      end

      def password_valid?(user, password)
        Auth::Password.verify?(password, user && user[:password_hash])
      end

      private

      attr_reader :database

      def users
        database[:users]
      end

      def normalize_account_profile(account_profile)
        raise ArgumentError, "Account profile must be a single value" if account_profile.is_a?(Array)

        account_profile.to_s
      end

      def validate_public_account_profile!(account_profile)
        return if PUBLIC_ACCOUNT_PROFILES.include?(account_profile)

        raise ArgumentError, "Account profile is not allowed for public registration"
      end

      def validate_status!(status)
        return if STATUSES.include?(status)

        raise ArgumentError, "User status is invalid"
      end

      def now
        Time.now.utc
      end
    end
  end
end
