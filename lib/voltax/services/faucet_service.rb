require_relative "../money"
require_relative "../repositories/ledger_repository"
require_relative "../repositories/wallet_repository"
require_relative "wallet_service"

module VoltaX
  module Services
    class FaucetService
      class AlreadyClaimed < StandardError; end

      REFERENCE_TYPE = "faucet".freeze
      REFERENCE_ID = "standard_faucet".freeze
      FUNDING = {
        "USDT" => "10000.00000000",
        "VOLT" => "1000.00000000"
      }.freeze

      def initialize(database:)
        @database = database
      end

      def claim(user_id:, idempotency_key:)
        database.transaction do
          lock_user!(user_id)

          if ledger_entries_for_key(user_id: user_id, idempotency_key: idempotency_key).any?
            return finance_state(user_id: user_id, funded: false, replayed: true)
          end

          raise AlreadyClaimed if faucet_entries_for_user(user_id: user_id).any?

          FUNDING.each do |asset, amount|
            wallet_service.credit_available(
              user_id: user_id,
              asset: asset,
              amount: amount,
              entry_type: "faucet_credit",
              reference_type: REFERENCE_TYPE,
              reference_id: REFERENCE_ID,
              idempotency_key: ledger_idempotency_key(idempotency_key: idempotency_key, asset: asset)
            )
          end

          finance_state(user_id: user_id, funded: true, replayed: false)
        end
      end

      private

      attr_reader :database

      def wallet_service
        @wallet_service ||= WalletService.new(database: database)
      end

      def wallet_repository
        @wallet_repository ||= Repositories::WalletRepository.new(database: database)
      end

      def ledger_repository
        @ledger_repository ||= Repositories::LedgerRepository.new(database: database)
      end

      def lock_user!(user_id)
        user = database[:users].where(id: user_id).for_update.first
        raise ArgumentError, "User not found" unless user
      end

      def finance_state(user_id:, funded:, replayed:)
        {
          funded: funded,
          replayed: replayed,
          wallets: wallet_repository.list_for_user(user_id: user_id),
          ledger_entries: ledger_repository.list_for_user(user_id: user_id)
        }
      end

      def ledger_entries_for_key(user_id:, idempotency_key:)
        database[:ledger_entries].where(
          user_id: user_id,
          idempotency_key: FUNDING.keys.map { |asset| ledger_idempotency_key(idempotency_key: idempotency_key, asset: asset) }
        ).all
      end

      def faucet_entries_for_user(user_id:)
        database[:ledger_entries].where(
          user_id: user_id,
          entry_type: "faucet_credit",
          reference_type: REFERENCE_TYPE,
          reference_id: REFERENCE_ID
        ).all
      end

      def ledger_idempotency_key(idempotency_key:, asset:)
        "faucet:#{idempotency_key}:#{asset}"
      end
    end
  end
end
