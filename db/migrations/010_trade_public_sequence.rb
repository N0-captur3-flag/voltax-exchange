Sequel.migration do
  up do
    run "CREATE SEQUENCE IF NOT EXISTS trades_public_sequence_seq"
    run <<~SQL
      SELECT setval(
        'trades_public_sequence_seq',
        COALESCE((SELECT MAX(public_sequence) FROM trades), 0) + 1,
        false
      )
    SQL

    alter_table(:trades) do
      set_column_default :public_sequence, Sequel.lit("nextval('trades_public_sequence_seq')")
    end

    run "ALTER SEQUENCE trades_public_sequence_seq OWNED BY trades.public_sequence"
  end

  down do
    alter_table(:trades) do
      set_column_default :public_sequence, nil
    end

    run "DROP SEQUENCE IF EXISTS trades_public_sequence_seq"
  end
end
