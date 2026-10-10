Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, null: false
      String :password_hash, null: false
      String :account_profile, null: false
      String :status, null: false, default: "active"
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique :username, name: :users_username_uidx
      constraint(:users_account_profile_check, account_profile: %w[spot liquidity partner auditor system_bot])
      constraint(:users_status_check, status: %w[active disabled])
    end

    create_table(:sessions) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      String :token_digest, null: false
      DateTime :expires_at, null: false
      DateTime :revoked_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique :token_digest, name: :sessions_token_digest_uidx
      index :user_id, name: :sessions_user_id_idx
      index :expires_at, name: :sessions_expires_at_idx
    end

    create_table(:markets) do
      primary_key :id
      String :symbol, null: false
      String :base_asset, null: false
      String :quote_asset, null: false
      BigDecimal :tick_size, size: [18, 8], null: false
      BigDecimal :lot_size, size: [18, 8], null: false
      String :status, null: false, default: "active"
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique :symbol, name: :markets_symbol_uidx
      constraint(:markets_status_check, status: %w[active paused disabled])
    end
  end
end
