class AddLeadDateToInwardDispatchRow < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_dispatch_rows, :lead_date, :datetime
  end
end
