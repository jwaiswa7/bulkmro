class SalesApproval < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_quote
  has_one :sales_order
  has_one :inquiry, :through => :sales_quote
end
