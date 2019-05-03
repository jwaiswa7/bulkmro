class AddBillingAndShippingAddressToSalesInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :billing_address_id, :integer
    add_column :sales_invoices, :shipping_address_id, :integer


    add_foreign_key :sales_invoices, :addresses, column: :billing_address_id
    add_foreign_key :sales_invoices, :addresses, column: :shipping_address_id
  end
end
