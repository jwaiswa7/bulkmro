# frozen_string_literal: true

class SalesOrderApproval < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  belongs_to :comment, class_name: 'InquiryComment', foreign_key: :inquiry_comment_id
end
