class AddReasonForRejectionToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :payment_request_approved_or_rejected, :integer
    add_column :payment_requests, :reason_for_rejection, :integer
  end
end
