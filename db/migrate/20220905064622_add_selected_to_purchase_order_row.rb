class AddSelectedToPurchaseOrderRow < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_rows, :selected, :boolean, default: true
  end
end
