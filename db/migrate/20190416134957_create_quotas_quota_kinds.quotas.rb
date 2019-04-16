# This migration comes from quotas (originally 20190407142852)
class CreateQuotasQuotaKinds < ActiveRecord::Migration
  def change
    create_table :quotas_quota_kinds do |t|
      t.string :name_ru,    null: false
      t.string :name_en,    null: false
      t.string :unit_ru,    null: false
      t.string :unit_en,    null: false
      t.string :comment_ru, null: false
      t.string :comment_en, null: false

      t.timestamps null: false
    end
  end
end
