class ChangeOrderNumbersType < ActiveRecord::Migration[5.2]
  def change
    change_column :sales_orders, :order_number, :integer, limit: 8
  end
end
