class AddInquiryStringFieldInBibleRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :bible_sales_orders, :inquiry, :string, default: nil
    add_column :bible_invoices, :inquiry, :string, default: nil
  end
end
