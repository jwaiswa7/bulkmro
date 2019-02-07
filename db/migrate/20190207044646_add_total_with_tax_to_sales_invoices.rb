class AddTotalWithTaxToSalesInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :calculated_total_with_tax, :decimal, default: 0.0
  end
end
