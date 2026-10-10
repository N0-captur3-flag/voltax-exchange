Sequel.migration do
  up do
    run "CREATE SEQUENCE IF NOT EXISTS public_feed_events_sequence_seq AS integer START WITH 1 INCREMENT BY 1 NO CYCLE"

    create_table(:public_feed_events) do
      primary_key :id
      Integer :sequence, null: false, default: Sequel.lit("nextval('public_feed_events_sequence_seq')")
      String :event_type, null: false
      foreign_key :market_id, :markets, on_delete: :restrict
      String :market_symbol, null: false
      BigDecimal :price, size: [36, 8]
      BigDecimal :quantity, size: [36, 8]
      String :public_reason
      String :payload_json, text: true, null: false, default: "{}"
      String :idempotency_key
      String :reference_type
      String :reference_id
      DateTime :created_at, null: false

      unique :sequence, name: :public_feed_events_sequence_uidx
      unique :idempotency_key, name: :public_feed_events_idempotency_key_uidx
      constraint(:public_feed_events_event_type_check, event_type: %w[
        trade_executed
        order_book_updated
        rfq_settled
        broker_report_period_closed
        market_signal_activated
        conditional_order_expired
        market_tick
      ])
      constraint(:public_feed_events_market_symbol_present, Sequel.lit("length(trim(market_symbol)) > 0"))
      constraint(:public_feed_events_price_positive, Sequel.lit("price IS NULL OR price > 0"))
      constraint(:public_feed_events_quantity_positive, Sequel.lit("quantity IS NULL OR quantity > 0"))
      constraint(:public_feed_events_payload_json_object, Sequel.lit("jsonb_typeof(payload_json::jsonb) = 'object'"))
      index [:market_symbol, :sequence], name: :public_feed_events_market_symbol_sequence_idx
      index [:market_id, :sequence], name: :public_feed_events_market_id_sequence_idx
      index [:event_type, :sequence], name: :public_feed_events_event_type_sequence_idx
      index :created_at, name: :public_feed_events_created_at_idx
      index [:reference_type, :reference_id], name: :public_feed_events_reference_idx
    end
  end

  down do
    drop_table(:public_feed_events)
    run "DROP SEQUENCE IF EXISTS public_feed_events_sequence_seq"
  end
end
