class CreateQuotasOverrideSemanticsData < ActiveRecord::Migration
  def change
    create_table :quotas_override_semantics_data do |t|
      t.string :priority, null: false
      t.string :state,    null: false

      t.timestamps null: false
    end
  end
end
