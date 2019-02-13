class AddManagerApprovedDate < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders,:manager_approved_date,:datetime
  end
end
