class AddStageToPaymentRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :stage, :integer
  end
end
