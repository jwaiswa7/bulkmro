class ChangeLateLeadDateReasonType < ActiveRecord::Migration[5.2]
  def change
    change_column :po_requests, :late_lead_date_reason, :text, default: nil
  end
end
