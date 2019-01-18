class AddRejectionReasonToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :rejection_reason, :integer, default:nil
  end
end
