class AddDescriptionAndSupplierBankDetailsToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :description, :string
    add_column :payment_requests, :supplier_bank_details, :text
  end
end
