class AddColumnInquiryProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_products, :lead_time, :string
    add_column :inquiry_products, :last_unit_price, :decimal
    add_column :inquiry_products, :basic_unit_price, :decimal
    add_column :inquiry_products, :gst, :float
    add_column :inquiry_products, :unit_freight, :decimal
    add_column :inquiry_products, :final_unit_price, :decimal
    add_column :inquiry_products, :total_price, :decimal
    add_column :inquiry_products, :remarks, :text
  end
end
