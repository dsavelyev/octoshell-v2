# This migration comes from quotas (originally 20190407152221)
class CreateQuotasQuotas < ActiveRecord::Migration
  def change
    create_table :quotas_quotas do |t|
      t.boolean :has_subject,   null: false
      t.integer :subject_id
      t.string  :subject_type
      t.integer :kind_id,       null: false
      t.integer :object_id,     null: false
      t.string  :object_type,   null: false
      t.string  :state,         null: false
      t.integer :current_value, limit: 8
      t.integer :desired_value, limit: 8

      t.timestamps null: false
    end

    add_index :quotas_quotas,
              [:has_subject, :subject_id, :subject_type, :kind_id, :object_id, :object_type],
              name: :i_quotas_on_subject_kind_and_object, unique: true
  end
end
