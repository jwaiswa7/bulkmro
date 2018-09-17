class InquiryComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :sales_order, optional: true
  has_one :approval, class_name: 'SalesOrderApproval'
  has_one :rejection, class_name: 'SalesOrderRejection'
end
