class AddOverallMarginPercentgaeToBibleOrderAndInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :bible_sales_orders, :overall_margin_percentage, :float, :default => 0
    add_column :bible_invoices, :overall_margin_percentage, :float, :default => 0
    add_column :bible_invoices, :company_name, :string, default: nil
    add_column :bible_sales_orders, :company_name, :string, default: nil
  end
end
