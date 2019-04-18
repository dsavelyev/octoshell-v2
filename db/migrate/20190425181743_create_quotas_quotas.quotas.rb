# This migration comes from quotas (originally 20190407152221)
class CreateQuotasQuotas < ActiveRecord::Migration
  def change
    create_table :quotas_quotas do |t|
      t.integer :_uniq_subject_id,   null: false
      t.string  :_uniq_subject_type, null: false
      t.integer :subject_id
      t.string  :subject_type
      t.integer :kind_id,            null: false
      t.integer :domain_id,          null: false
      t.string  :domain_type,        null: false
      t.string  :state,              null: false
      t.integer :current_value,      limit: 8
      t.integer :desired_value,      limit: 8

      t.timestamps null: false
    end

    add_index :quotas_quotas,
              [:_uniq_subject_id, :_uniq_subject_type, :kind_id, :domain_id, :domain_type],
              name: :i_quotas_on_subject_kind_and_domain, unique: true
  end
end
