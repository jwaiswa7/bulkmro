class AddRequestOwnerToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :request_owner, :integer
  end
end
