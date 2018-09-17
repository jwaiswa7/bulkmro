class SalesOrder < ApplicationRecord
  COMMENTS_CLASS = 'InquiryComment'
  REJECTIONS_CLASS = 'SalesOrderRejection'
  APPROVALS_CLASS = 'SalesOrderApproval'

  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasApproveableStatus
  include Mixins::HasComments
  include Mixins::CanBeSent

  has_closure_tree({ name_column: :to_s })

  belongs_to :sales_quote
  has_one :inquiry, :through => :sales_quote
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_many :rows, -> { joins(:inquiry_product).order('inquiry_products.sr_no ASC') }, class_name: 'SalesOrderRow', inverse_of: :sales_order
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['sales_quote_row_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  has_many :sales_quote_rows, :through => :sales_quote

  delegate :conversion_rate, to: :inquiry_currency

  def calculated_total
    rows.map { |row| row.unit_selling_price * row.quantity }.sum
  end
end