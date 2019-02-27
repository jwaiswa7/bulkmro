class AddLeadDateToMprRow < ActiveRecord::Migration[5.2]
  def change
    add_column :mpr_rows, :lead_date, :datetime
  end
end
