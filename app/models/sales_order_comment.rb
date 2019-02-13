

class SalesOrderComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  has_one :approval, class_name: "SalesOrderApproval"
  has_one :rejection, class_name: "SalesOrderRejection"
end
