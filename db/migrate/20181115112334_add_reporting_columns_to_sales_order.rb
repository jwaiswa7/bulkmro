class AddReportingColumnsToSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :mis_date, :date
    add_column :sales_orders, :report_total, :decimal
  end
end
