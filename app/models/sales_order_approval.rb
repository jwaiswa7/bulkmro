class SalesOrderApproval < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  belongs_to :comment, class_name: 'SalesOrderComment', foreign_key: :sales_order_comment_id
end
