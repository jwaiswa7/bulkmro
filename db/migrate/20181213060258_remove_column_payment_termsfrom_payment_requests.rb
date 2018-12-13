class RemoveColumnPaymentTermsfromPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :payment_requests, :payment_terms
  end
end
