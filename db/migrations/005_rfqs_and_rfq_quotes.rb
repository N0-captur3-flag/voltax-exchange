Sequel.migration do
  up do
    create_table(:rfqs) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :restrict
      foreign_key :market_id, :markets, null: false, on_delete: :restrict
      String :side, null: false
      BigDecimal :quantity, size: [36, 8], null: false
      BigDecimal :target_price, size: [36, 8]
      String :status, null: false
      String :public_comment
      String :delivery_terms, null: false
      Integer :accepted_quote_id
      DateTime :expires_at, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      DateTime :cancelled_at

      constraint(:rfqs_side_check, side: %w[buy sell])
      constraint(:rfqs_status_check, status: %w[open quoted accepted settled cancelled expired])
      constraint(:rfqs_quantity_positive, Sequel[:quantity] > 0)
      constraint(:rfqs_target_price_positive, Sequel.lit("target_price IS NULL OR target_price > 0"))
      index :user_id, name: :rfqs_user_id_idx
      index [:user_id, :status], name: :rfqs_user_id_status_idx
      index [:market_id, :status, :expires_at, :id], name: :rfqs_board_idx
      index :accepted_quote_id, name: :rfqs_accepted_quote_id_idx
    end

    create_table(:rfq_quotes) do
      primary_key :id
      foreign_key :rfq_id, :rfqs, null: false, on_delete: :restrict
      foreign_key :maker_user_id, :users, null: false, on_delete: :restrict
      BigDecimal :price, size: [36, 8], null: false
      BigDecimal :quantity, size: [36, 8], null: false
      String :status, null: false
      DateTime :expires_at, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      DateTime :cancelled_at

      unique [:rfq_id, :maker_user_id], name: :rfq_quotes_rfq_id_maker_user_id_uidx
      constraint(:rfq_quotes_status_check, status: %w[submitted accepted rejected withdrawn expired])
      constraint(:rfq_quotes_price_positive, Sequel[:price] > 0)
      constraint(:rfq_quotes_quantity_positive, Sequel[:quantity] > 0)
      index :rfq_id, name: :rfq_quotes_rfq_id_idx
      index :maker_user_id, name: :rfq_quotes_maker_user_id_idx
      index [:rfq_id, :status], name: :rfq_quotes_rfq_id_status_idx
      index [:maker_user_id, :status], name: :rfq_quotes_maker_user_id_status_idx
    end

    alter_table(:rfqs) do
      add_foreign_key [:accepted_quote_id], :rfq_quotes, name: :rfqs_accepted_quote_id_fkey, on_delete: :restrict
    end
  end

  down do
    alter_table(:rfqs) do
      drop_foreign_key [:accepted_quote_id], name: :rfqs_accepted_quote_id_fkey
    end
    drop_table(:rfq_quotes)
    drop_table(:rfqs)
  end
end
