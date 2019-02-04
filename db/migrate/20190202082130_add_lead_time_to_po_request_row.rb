class AddLeadTimeToPoRequestRow < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :lead_time, :date
  end
end
