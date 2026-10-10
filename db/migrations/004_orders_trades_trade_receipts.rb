Sequel.migration do
  change do
    create_table(:orders) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :restrict
      foreign_key :market_id, :markets, null: false, on_delete: :restrict
      String :side, null: false
      String :order_type, null: false
      BigDecimal :limit_price, size: [36, 8], null: false
      BigDecimal :original_quantity, size: [36, 8], null: false
      BigDecimal :filled_quantity, size: [36, 8], null: false, default: 0
      BigDecimal :remaining_quantity, size: [36, 8], null: false
      String :status, null: false
      String :client_order_id
      String :execution_memo
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      DateTime :cancelled_at

      unique [:user_id, :client_order_id], name: :orders_user_id_client_order_id_uidx
      constraint(:orders_side_check, side: %w[buy sell])
      constraint(:orders_order_type_check, order_type: %w[limit])
      constraint(:orders_status_check, status: %w[open partially_filled filled cancelled])
      constraint(:orders_limit_price_positive, Sequel[:limit_price] > 0)
      constraint(:orders_original_quantity_positive, Sequel[:original_quantity] > 0)
      constraint(:orders_filled_quantity_nonnegative, Sequel[:filled_quantity] >= 0)
      constraint(:orders_remaining_quantity_nonnegative, Sequel[:remaining_quantity] >= 0)
      constraint(:orders_quantity_sum_check, Sequel.lit("filled_quantity + remaining_quantity = original_quantity"))
      index :user_id, name: :orders_user_id_idx
      index [:user_id, :status], name: :orders_user_id_status_idx
      index [:market_id, :status, :side, :limit_price, :created_at, :id], name: :orders_matching_idx
    end

    create_table(:trades) do
      primary_key :id
      foreign_key :market_id, :markets, null: false, on_delete: :restrict
      foreign_key :buy_order_id, :orders, null: false, on_delete: :restrict
      foreign_key :sell_order_id, :orders, null: false, on_delete: :restrict
      foreign_key :maker_order_id, :orders, null: false, on_delete: :restrict
      foreign_key :taker_order_id, :orders, null: false, on_delete: :restrict
      Integer :public_sequence, null: false
      BigDecimal :execution_price, size: [36, 8], null: false
      BigDecimal :executed_quantity, size: [36, 8], null: false
      BigDecimal :quote_amount, size: [36, 8], null: false
      String :aggressor_side, null: false
      DateTime :created_at, null: false

      unique :public_sequence, name: :trades_public_sequence_uidx
      constraint(:trades_execution_price_positive, Sequel[:execution_price] > 0)
      constraint(:trades_executed_quantity_positive, Sequel[:executed_quantity] > 0)
      constraint(:trades_quote_amount_positive, Sequel[:quote_amount] > 0)
      constraint(:trades_aggressor_side_check, aggressor_side: %w[buy sell])
      constraint(:trades_buy_sell_distinct_check, Sequel.lit("buy_order_id <> sell_order_id"))
      constraint(:trades_maker_taker_distinct_check, Sequel.lit("maker_order_id <> taker_order_id"))
      index [:market_id, :public_sequence], name: :trades_market_id_public_sequence_idx
      index :buy_order_id, name: :trades_buy_order_id_idx
      index :sell_order_id, name: :trades_sell_order_id_idx
    end

    create_table(:trade_receipts) do
      primary_key :id
      foreign_key :trade_id, :trades, null: false, on_delete: :restrict
      foreign_key :user_id, :users, null: false, on_delete: :restrict
      foreign_key :order_id, :orders, null: false, on_delete: :restrict
      String :client_order_id
      String :client_reference
      String :side, null: false
      String :liquidity_role, null: false
      String :market_symbol, null: false
      BigDecimal :price, size: [36, 8], null: false
      BigDecimal :quantity, size: [36, 8], null: false
      BigDecimal :quote_amount, size: [36, 8], null: false
      String :fee_asset
      BigDecimal :fee_amount, size: [36, 8], null: false, default: 0
      String :debit_asset, null: false
      BigDecimal :debit_amount, size: [36, 8], null: false
      String :credit_asset, null: false
      BigDecimal :credit_amount, size: [36, 8], null: false
      String :settlement_status, null: false
      DateTime :created_at, null: false

      unique [:trade_id, :user_id], name: :trade_receipts_trade_id_user_id_uidx
      constraint(:trade_receipts_side_check, side: %w[buy sell])
      constraint(:trade_receipts_liquidity_role_check, liquidity_role: %w[maker taker])
      constraint(:trade_receipts_price_positive, Sequel[:price] > 0)
      constraint(:trade_receipts_quantity_positive, Sequel[:quantity] > 0)
      constraint(:trade_receipts_quote_amount_positive, Sequel[:quote_amount] > 0)
      constraint(:trade_receipts_fee_amount_nonnegative, Sequel[:fee_amount] >= 0)
      constraint(:trade_receipts_debit_amount_positive, Sequel[:debit_amount] > 0)
      constraint(:trade_receipts_credit_amount_positive, Sequel[:credit_amount] > 0)
      constraint(:trade_receipts_settlement_status_check, settlement_status: %w[settled])
      index :user_id, name: :trade_receipts_user_id_idx
      index [:user_id, :order_id], name: :trade_receipts_user_id_order_id_idx
      index [:user_id, :trade_id], name: :trade_receipts_user_id_trade_id_idx
    end
  end
end
