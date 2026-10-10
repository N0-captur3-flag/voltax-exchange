require_relative "../money"

module VoltaX
  module Repositories
    class LedgerRepository
      class AppendOnlyError < StandardError; end

      ENTRY_TYPES = %w[faucet_credit lock unlock spend release adjustment_reversal].freeze
      BALANCE_BUCKETS = %w[available locked].freeze
      SUPPORTED_ASSETS = %w[VOLT USDT].freeze

      def initialize(database:)
        @database = database
      end

      def append(user_id:, wallet_id:, asset:, balance_bucket:, amount:, entry_type:, reference_type: nil, reference_id: nil,
                 idempotency_key: nil)
        asset = normalize_asset(asset)
        balance_bucket = normalize_balance_bucket(balance_bucket)
        entry_type = normalize_entry_type(entry_type)
        amount = Money.coerce_decimal(amount)
        raise ArgumentError, "Ledger amount must be nonzero" if amount.zero?

        validate_wallet!(user_id: user_id, wallet_id: wallet_id, asset: asset)

        id = ledger_entries.insert(
          user_id: user_id,
          wallet_id: wallet_id,
          asset: asset,
          balance_bucket: balance_bucket,
          amount: amount,
          entry_type: entry_type,
          reference_type: optional_string(reference_type),
          reference_id: optional_string(reference_id),
          idempotency_key: optional_string(idempotency_key),
          created_at: Time.now.utc
        )
        find_appended_entry(id)
      end

      def find_by_idempotency_key(user_id:, idempotency_key:)
        return nil if idempotency_key.to_s.empty?

        ledger_entries.where(user_id: user_id, idempotency_key: idempotency_key.to_s).first
      end

      def list_for_user(user_id:)
        ledger_entries.where(user_id: user_id).order(:id).all
      end

      def update(*)
        raise AppendOnlyError, "Ledger entries are append-only"
      end

      def delete(*)
        raise AppendOnlyError, "Ledger entries are append-only"
      end

      private

      attr_reader :database

      def ledger_entries
        database[:ledger_entries]
      end

      def wallets
        database[:wallets]
      end

      def find_appended_entry(id)
        ledger_entries.where(id: id).first
      end

      def validate_wallet!(user_id:, wallet_id:, asset:)
        wallet = wallets.where(id: wallet_id).first
        unless wallet && wallet[:user_id] == user_id && wallet[:asset] == asset
          raise ArgumentError, "Ledger wallet does not match user and asset"
        end
      end

      def normalize_asset(asset)
        normalized = asset.to_s
        raise ArgumentError, "Asset is not supported" unless SUPPORTED_ASSETS.include?(normalized)

        normalized
      end

      def normalize_balance_bucket(balance_bucket)
        normalized = balance_bucket.to_s
        raise ArgumentError, "Balance bucket is invalid" unless BALANCE_BUCKETS.include?(normalized)

        normalized
      end

      def normalize_entry_type(entry_type)
        normalized = entry_type.to_s
        raise ArgumentError, "Ledger entry type is invalid" unless ENTRY_TYPES.include?(normalized)

        normalized
      end

      def optional_string(value)
        return nil if value.nil?

        value.to_s
      end
    end
  end
end
