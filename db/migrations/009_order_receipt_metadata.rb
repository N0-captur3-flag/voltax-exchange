Sequel.migration do
  change do
    alter_table(:orders) do
      add_column :client_reference, String
    end
  end
end
