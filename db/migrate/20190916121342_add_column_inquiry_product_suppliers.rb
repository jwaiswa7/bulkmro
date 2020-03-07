class AddColumnInquiryProductSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_product_suppliers, :lead_time, :string
    add_column :inquiry_product_suppliers, :last_unit_price, :decimal
    add_column :inquiry_product_suppliers, :gst, :float
    add_column :inquiry_product_suppliers, :unit_freight, :decimal
    add_column :inquiry_product_suppliers, :final_unit_price, :decimal
    add_column :inquiry_product_suppliers, :total_price, :decimal
    add_column :inquiry_product_suppliers, :remarks, :text
  end
end
