class AddRemarkToSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :remark, :string
  end
end
