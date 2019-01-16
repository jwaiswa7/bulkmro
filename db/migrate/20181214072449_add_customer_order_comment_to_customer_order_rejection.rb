class AddCustomerOrderCommentToCustomerOrderRejection < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_order_rejections, :customer_order_comment, foreign_key: true
  end
end
