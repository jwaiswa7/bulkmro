class AddWeightToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :weight, :decimal
  end
end
