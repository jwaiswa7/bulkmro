class AddCustomerOrderCommentToCustomerOrderApproval < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_order_approvals, :customer_order_comment, foreign_key: true
  end
end
