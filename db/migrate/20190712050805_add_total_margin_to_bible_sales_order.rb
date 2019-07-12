class AddTotalMarginToBibleSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :bible_sales_orders, :total_margin, :float
  end
end
