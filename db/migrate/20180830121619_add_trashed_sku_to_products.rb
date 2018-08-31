class AddTrashedSkuToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :trashed_sku, :string, index: true
  end
end
