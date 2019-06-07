# This migration comes from quotas (originally 20190408091702)
class CreateQuotasOverrideSemanticsData < ActiveRecord::Migration
  def change
    create_table :quotas_override_semantics_data do |t|
      t.string  :current_priority, null: false
      t.string  :desired_priority, null: false
      t.boolean :syncing,          null: false, default: false
      t.integer :lock_version,     null: false, limit: 8, default: 1

      t.timestamps null: false
    end
  end
end
