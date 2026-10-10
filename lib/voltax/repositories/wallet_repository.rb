require_relative "../money"

module VoltaX
  module Repositories
    class WalletRepository
      SUPPORTED_ASSETS = %w[VOLT USDT].freeze

      def initialize(database:)
        @database = database
      end

      def create_if_missing(user_id:, asset:)
        asset = normalize_asset(asset)
        existing = find_by_user_and_asset(user_id: user_id, asset: asset)
        return existing if existing

        timestamp = now
        id = wallets.insert(
          user_id: user_id,
          asset: asset,
          available_balance: Money.zero,
          locked_balance: Money.zero,
          created_at: timestamp,
          updated_at: timestamp
        )
        find_created_wallet(id)
      rescue Sequel::UniqueConstraintViolation
        find_by_user_and_asset(user_id: user_id, asset: asset)
      end

      def find_by_id_for_user(user_id:, id:)
        wallets.where(id: id, user_id: user_id).first
      end

      def find_by_user_and_asset(user_id:, asset:)
        wallets.where(user_id: user_id, asset: normalize_asset(asset)).first
      end

      def lock_by_user_and_asset(user_id:, asset:)
        wallets.where(user_id: user_id, asset: normalize_asset(asset)).for_update.first
      end

      def list_for_user(user_id:)
        wallets.where(user_id: user_id).order(:asset).all
      end

      def apply_delta(wallet_id:, user_id:, available_delta:, locked_delta:)
        available_delta = Money.coerce_decimal(available_delta)
        locked_delta = Money.coerce_decimal(locked_delta)
        timestamp = now
        changed = wallets.where(id: wallet_id, user_id: user_id).update(
          available_balance: Sequel[:available_balance] + available_delta,
          locked_balance: Sequel[:locked_balance] + locked_delta,
          updated_at: timestamp
        )
        raise ArgumentError, "Wallet not found" if changed != 1

        find_by_id_for_user(user_id: user_id, id: wallet_id)
      end

      private

      attr_reader :database

      def wallets
        database[:wallets]
      end

      def find_created_wallet(id)
        wallets.where(id: id).first
      end

      def normalize_asset(asset)
        normalized = asset.to_s
        raise ArgumentError, "Asset is not supported" unless SUPPORTED_ASSETS.include?(normalized)

        normalized
      end

      def now
        Time.now.utc
      end
    end
  end
end
