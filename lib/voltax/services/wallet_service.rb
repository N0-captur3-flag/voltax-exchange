require_relative "../money"
require_relative "../repositories/ledger_repository"
require_relative "../repositories/wallet_repository"

module VoltaX
  module Services
    class WalletService
      def initialize(database:)
        @database = database
      end

      def credit_available(user_id:, asset:, amount:, entry_type: "faucet_credit", reference_type: nil, reference_id: nil,
                           idempotency_key: nil)
        amount = Money.coerce_decimal(amount)
        raise ArgumentError, "Credit amount must be positive" unless Money.positive?(amount)

        database.transaction do
          existing = ledger_repository.find_by_idempotency_key(user_id: user_id, idempotency_key: idempotency_key)
          if existing
            wallet = wallet_repository.find_by_id_for_user(user_id: user_id, id: existing[:wallet_id])
            return { wallet: wallet, ledger_entry: existing, replayed: true }
          end

          wallet_repository.create_if_missing(user_id: user_id, asset: asset)
          wallet = wallet_repository.lock_by_user_and_asset(user_id: user_id, asset: asset)
          ledger_entry = ledger_repository.append(
            user_id: user_id,
            wallet_id: wallet[:id],
            asset: asset,
            balance_bucket: "available",
            amount: amount,
            entry_type: entry_type,
            reference_type: reference_type,
            reference_id: reference_id,
            idempotency_key: idempotency_key
          )
          updated_wallet = wallet_repository.apply_delta(
            wallet_id: wallet[:id],
            user_id: user_id,
            available_delta: amount,
            locked_delta: Money.zero
          )

          { wallet: updated_wallet, ledger_entry: ledger_entry, replayed: false }
        end
      end

      private

      attr_reader :database

      def wallet_repository
        @wallet_repository ||= Repositories::WalletRepository.new(database: database)
      end

      def ledger_repository
        @ledger_repository ||= Repositories::LedgerRepository.new(database: database)
      end
    end
  end
end
