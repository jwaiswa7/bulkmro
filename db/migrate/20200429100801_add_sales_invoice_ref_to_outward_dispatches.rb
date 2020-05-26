class AddSalesInvoiceRefToOutwardDispatches < ActiveRecord::Migration[5.2]
  def change
    add_reference :outward_dispatches, :sales_invoice, foreign_key: true
    add_reference :packing_slip_rows, :sales_invoice_row, foreign_key: true
  end
end
