class AddCustomerPoSheetToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :customer_po_sheet, :string
  end
end
