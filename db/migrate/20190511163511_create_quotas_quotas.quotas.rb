# This migration comes from quotas (originally 20190407152221)
class CreateQuotasQuotas < ActiveRecord::Migration
  def change
    create_table :quotas_quotas do |t|
      t.integer    :_uniq_subject_id,   null: false
      t.string     :_uniq_subject_type, null: false
      t.belongs_to :subject,            polymorphic: true
      t.belongs_to :kind,               null: false
      t.belongs_to :domain,             null: false, polymorphic: true
      t.string     :state,              null: false, default: "never_synced"
      t.integer    :current_value,      limit: 8
      t.integer    :desired_value,      limit: 8
      t.integer    :lock_version,       limit: 8, null: false, default: 1

      t.timestamps null: false
    end

    add_index :quotas_quotas,
              [:_uniq_subject_id, :_uniq_subject_type, :kind_id, :domain_id, :domain_type],
              name: :i_quotas_on_subject_kind_and_domain, unique: true
  end
end
