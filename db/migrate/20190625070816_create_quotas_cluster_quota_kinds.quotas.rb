# This migration comes from quotas (originally 20190407145821)
class CreateQuotasClusterQuotaKinds < ActiveRecord::Migration
  def change
    create_table :quotas_cluster_quota_kinds do |t|
      t.belongs_to :cluster,               null: false
      t.belongs_to :quota_kind,            null: false
      t.string     :name_on_cluster,       null: false
      t.string     :comment_ru
      t.string     :comment_en
      t.boolean    :applies_to_partitions, null: false
      t.string     :semantics_type,        null: false
      t.belongs_to :semantics_data,        polymorphic: true

      t.timestamps null: false
    end

    add_index :quotas_cluster_quota_kinds, [:cluster_id, :quota_kind_id],
              name: :i_cqk_on_cluster_and_quota_kind, unique: true
    add_index :quotas_cluster_quota_kinds, [:cluster_id, :name_on_cluster],
              name: :i_cqk_on_cluster_and_name_on_cluster, unique: true
  end
end
