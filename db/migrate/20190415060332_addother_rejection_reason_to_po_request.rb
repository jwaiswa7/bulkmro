class AddotherRejectionReasonToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :other_rejection_reason, :text, default:nil
  end
end
