class AddArInvoiceReferenceToInwardDispatch < ActiveRecord::Migration[5.2]
  def change
    add_reference :inward_dispatches, :ar_invoice_request
    add_reference :inward_dispatches, :sales_order
  end
end
