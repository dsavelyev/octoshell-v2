# This migration comes from quotas (originally 20190407145821)
class CreateQuotasClusterQuotaKinds < ActiveRecord::Migration
  def change
    create_table :quotas_cluster_quota_kinds do |t|
      t.integer :cluster_id,            null: false
      t.integer :quota_kind_id,         null: false
      t.string  :machine_name,          null: false
      t.string  :comment_ru,            null: false
      t.string  :comment_en,            null: false
      t.boolean :applies_to_partitions, null: false
      t.string  :semantics_type,        null: false
      t.integer :semantics_data_id
      t.string  :semantics_data_type

      t.timestamps null: false
    end

    add_index :quotas_cluster_quota_kinds, [:cluster_id, :quota_kind_id],
              name: :i_cqk_on_cluster_and_quota_kind, unique: true
    add_index :quotas_cluster_quota_kinds, [:cluster_id, :machine_name],
              name: :i_cqk_on_cluster_and_machine_name, unique: true
  end
end
