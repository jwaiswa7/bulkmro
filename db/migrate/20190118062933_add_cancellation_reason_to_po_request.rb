class AddCancellationReasonToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :cancellation_reason, :text, default:nil
  end
end
