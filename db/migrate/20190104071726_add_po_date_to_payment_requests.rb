class AddPoDateToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :po_date, :string
  end
end
