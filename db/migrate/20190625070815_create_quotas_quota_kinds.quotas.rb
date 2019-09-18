# This migration comes from quotas (originally 20190407142852)
class CreateQuotasQuotaKinds < ActiveRecord::Migration
  def change
    create_table :quotas_quota_kinds do |t|
      t.string :name_ru
      t.string :name_en
      t.string :unit_ru
      t.string :unit_en
      t.string :comment_ru
      t.string :comment_en

      t.timestamps null: false
    end
  end
end
