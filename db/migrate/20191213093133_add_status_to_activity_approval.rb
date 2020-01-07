class AddStatusToActivityApproval < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_approvals, :activity_status, :integer, default: 10
  end
end
