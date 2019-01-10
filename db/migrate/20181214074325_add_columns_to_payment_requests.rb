class AddColumnsToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    change_column :payment_requests, :utr_number, :string
    add_column :payment_requests, :payment_type, :integer
  end
end
