# This migration comes from quotas (originally 20190408091702)
class CreateQuotasOverrideSemanticsData < ActiveRecord::Migration
  def change
    create_table :quotas_override_semantics_data do |t|
      t.string :priority,         null: false
      t.string :desired_priority, null: false
      t.string :state,            null: false

      t.timestamps null: false
    end
  end
end
