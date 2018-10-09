class AddWeightInKgsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :weight_in_kgs, :decimal, default: 0.0
  end
end
