class AddCostPriceFieldToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :supplier_unit_cost_price, :decimal
  end
end
