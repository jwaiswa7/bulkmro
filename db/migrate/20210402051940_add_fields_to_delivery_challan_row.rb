class AddFieldsToDeliveryChallanRow < ActiveRecord::Migration[5.2]
  def change
    add_column :delivery_challan_rows, :unit_selling_price, :decimal
    add_column :delivery_challan_rows, :legacy_applicable_tax, :string
    add_column :delivery_challan_rows, :legacy_applicable_tax_percentage, :decimal
  end
end
