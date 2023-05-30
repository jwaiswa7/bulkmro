class AddMissingIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :customer_products, [:company_id, :sku], unique: false
  end
end
