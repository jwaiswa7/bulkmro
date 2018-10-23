class InquiryComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :sales_order, required: false
  has_one :approval, class_name: 'SalesOrderApproval', dependent: :destroy
  has_one :rejection, class_name: 'SalesOrderRejection', dependent: :destroy
end
