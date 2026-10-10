Sequel.migration do
  change do
    create_table(:broker_campaigns) do
      primary_key :id
      foreign_key :broker_user_id, :users, null: false, on_delete: :restrict
      String :campaign_code, null: false
      String :name, null: false
      String :status, null: false
      DateTime :starts_at
      DateTime :ends_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique :campaign_code, name: :broker_campaigns_campaign_code_uidx
      constraint(:broker_campaigns_status_check, status: %w[active paused closed cancelled])
      constraint(:broker_campaigns_code_present, Sequel.lit("length(trim(campaign_code)) > 0"))
      constraint(:broker_campaigns_name_present, Sequel.lit("length(trim(name)) > 0"))
      constraint(:broker_campaigns_time_window_check, Sequel.lit("starts_at IS NULL OR ends_at IS NULL OR starts_at < ends_at"))
      index :broker_user_id, name: :broker_campaigns_broker_user_id_idx
      index [:broker_user_id, :status], name: :broker_campaigns_broker_user_id_status_idx
      index [:campaign_code, :status], name: :broker_campaigns_campaign_code_status_idx
    end

    create_table(:broker_attributions) do
      primary_key :id
      foreign_key :campaign_id, :broker_campaigns, null: false, on_delete: :restrict
      foreign_key :broker_user_id, :users, null: false, on_delete: :restrict
      foreign_key :trader_user_id, :users, null: false, on_delete: :restrict
      String :source, null: false
      String :status, null: false
      String :user_reference
      DateTime :attributed_at, null: false
      DateTime :revoked_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:campaign_id, :trader_user_id], name: :broker_attributions_campaign_id_trader_user_id_uidx
      constraint(:broker_attributions_source_check, source: %w[self_service])
      constraint(:broker_attributions_status_check, status: %w[active revoked])
      constraint(:broker_attributions_revoked_at_check, Sequel.lit("(status = 'revoked' AND revoked_at IS NOT NULL) OR (status = 'active' AND revoked_at IS NULL)"))
      index :campaign_id, name: :broker_attributions_campaign_id_idx
      index :broker_user_id, name: :broker_attributions_broker_user_id_idx
      index [:broker_user_id, :status], name: :broker_attributions_broker_user_id_status_idx
      index [:trader_user_id, :status], name: :broker_attributions_trader_user_id_status_idx
    end
  end
end
