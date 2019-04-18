# This migration comes from quotas (originally 20190422021511)
class AddUsersCanRequestQuotasToCoreProject < ActiveRecord::Migration
  def change
    add_column :core_projects, :users_can_request_quotas, :boolean, default: false, null: false
  end
end
