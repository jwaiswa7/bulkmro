class AddReportFieldsToSalesInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :report_total, :decimal
    add_column :sales_invoices, :remark, :string
    add_column :sales_invoices, :mis_date, :date
  end
end
