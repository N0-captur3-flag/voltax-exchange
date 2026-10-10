Sequel.migration do
  change do
    create_table(:conditional_orders) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :restrict
      foreign_key :market_id, :markets, null: false, on_delete: :restrict
      foreign_key :triggered_order_id, :orders, on_delete: :restrict
      String :side, null: false
      String :order_type, null: false
      String :trigger_type, null: false
      BigDecimal :trigger_price, size: [36, 8], null: false
      BigDecimal :limit_price, size: [36, 8], null: false
      BigDecimal :quantity, size: [36, 8], null: false
      String :status, null: false
      String :client_order_id
      String :signal_context, size: 512
      String :trigger_idempotency_key
      DateTime :expires_at
      DateTime :triggered_at
      DateTime :cancelled_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:user_id, :client_order_id], name: :conditional_orders_user_id_client_order_id_uidx
      unique :trigger_idempotency_key, name: :conditional_orders_trigger_idempotency_key_uidx
      constraint(:conditional_orders_side_check, side: %w[buy sell])
      constraint(:conditional_orders_type_check, order_type: %w[limit])
      constraint(:conditional_orders_trigger_type_check, trigger_type: %w[
        last_trade_price_at_or_above
        last_trade_price_at_or_below
      ])
      constraint(:conditional_orders_status_check, status: %w[
        pending
        triggered
        placed
        cancelled
        expired
        rejected
      ])
      constraint(:conditional_orders_trigger_price_positive, Sequel[:trigger_price] > 0)
      constraint(:conditional_orders_limit_price_positive, Sequel[:limit_price] > 0)
      constraint(:conditional_orders_quantity_positive, Sequel[:quantity] > 0)
      constraint(:conditional_orders_triggered_order_status_check,
                 Sequel.lit("(triggered_order_id IS NULL AND status != 'placed') OR (triggered_order_id IS NOT NULL AND status = 'placed')"))
      constraint(:conditional_orders_triggered_at_check,
                 Sequel.lit("(status IN ('triggered', 'placed') AND triggered_at IS NOT NULL) OR (status NOT IN ('triggered', 'placed'))"))
      constraint(:conditional_orders_cancelled_at_check,
                 Sequel.lit("(cancelled_at IS NULL AND status != 'cancelled') OR (cancelled_at IS NOT NULL AND status = 'cancelled')"))
      index :user_id, name: :conditional_orders_user_id_idx
      index [:user_id, :status], name: :conditional_orders_user_id_status_idx
      index [:market_id, :status, :trigger_type, :trigger_price, :created_at, :id], name: :conditional_orders_pending_work_idx
      index [:market_id, :status, :expires_at, :id], name: :conditional_orders_expiry_idx
      index :triggered_order_id, name: :conditional_orders_triggered_order_id_idx
    end
  end
end
