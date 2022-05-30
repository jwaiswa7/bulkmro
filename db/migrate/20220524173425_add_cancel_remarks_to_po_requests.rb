class AddCancelRemarksToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :cancellation_remarks, :text, default:nil
  end
end
