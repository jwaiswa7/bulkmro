class AddLateLeadDateReasonToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :late_lead_date_reason, :string, default: nil
  end
end
