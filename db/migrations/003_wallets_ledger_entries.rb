Sequel.migration do
  change do
    create_table(:wallets) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      String :asset, null: false
      BigDecimal :available_balance, size: [36, 8], null: false, default: 0
      BigDecimal :locked_balance, size: [36, 8], null: false, default: 0
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:user_id, :asset], name: :wallets_user_id_asset_uidx
      constraint(:wallets_asset_check, asset: %w[VOLT USDT])
      constraint(:wallets_available_balance_nonnegative, Sequel[:available_balance] >= 0)
      constraint(:wallets_locked_balance_nonnegative, Sequel[:locked_balance] >= 0)
      index :user_id, name: :wallets_user_id_idx
    end

    create_table(:ledger_entries) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :wallet_id, :wallets, null: false, on_delete: :restrict
      String :asset, null: false
      String :balance_bucket, null: false
      BigDecimal :amount, size: [36, 8], null: false
      String :entry_type, null: false
      String :reference_type
      String :reference_id
      String :idempotency_key
      DateTime :created_at, null: false

      unique [:user_id, :idempotency_key], name: :ledger_entries_user_id_idempotency_key_uidx
      constraint(:ledger_entries_asset_check, asset: %w[VOLT USDT])
      constraint(:ledger_entries_balance_bucket_check, balance_bucket: %w[available locked])
      constraint(
        :ledger_entries_entry_type_check,
        entry_type: %w[faucet_credit lock unlock spend release adjustment_reversal]
      )
      constraint(:ledger_entries_amount_nonzero, Sequel.lit("amount <> 0"))
      index :user_id, name: :ledger_entries_user_id_idx
      index :wallet_id, name: :ledger_entries_wallet_id_idx
      index [:reference_type, :reference_id], name: :ledger_entries_reference_idx
    end
  end
end
