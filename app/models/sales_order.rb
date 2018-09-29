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
  include Mixins::CanBeSynced
  include Mixins::HasRowCalculations

  has_closure_tree({name_column: :to_s})

  belongs_to :sales_quote
  has_one :inquiry, :through => :sales_quote
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_many :rows, -> {joins(:inquiry_product).order('inquiry_products.sr_no ASC')}, class_name: 'SalesOrderRow', inverse_of: :sales_order
  accepts_nested_attributes_for :rows, reject_if: lambda {|attributes| attributes['sales_quote_row_id'].blank? && attributes['id'].blank?}, allow_destroy: true
  has_many :sales_quote_rows, :through => :sales_quote
  has_one :confirmation, :class_name => 'SalesOrderConfirmation'

  delegate :conversion_rate, to: :inquiry_currency

  attr_accessor :confirm_ord_values, :confirm_tax_rates, :confirm_hsn_codes, :confirm_billing_address, :confirm_shipping_address, :confirm_customer_po_no

=begin
  enum legacy_request_status: {
      :'requested' => 10,
      :'SAP Approval Pending' => 20,
      :'rejected' => 30,
      :'SAP Rejected' => 40,
      :'Cancelled' => 50,
      :'approved' => 60,
      :'Order Deleted' => 70
  }
=end

  enum remote_status: {
      :'Supplier PO: Request Pending' => 17,
      :'Supplier PO: Partially Created' => 18,
      :'Partially Shipped' => 19,
      :'Partially Invoiced' => 20,
      :'Partially Delivered: GRN Pending' => 21,
      :'Partially Delivered: GRN Received' => 22,
      :'Supplier PO: Created' => 23,
      :'Shipped' => 24,
      :'Invoiced' => 25,
      :'Delivered: GRN Pending' => 26,
      :'Delivered: GRN Received' => 27,
      :'Partial Payment Received' => 28,
      :'Payment Received (Closed)' => 29,
      :'Cancelled' => 30,
      :'Short Close' => 31,
      :'Processing' => 32,
      :'Material Ready For Dispatch' => 33
  }

  def confirmed?
    self.confirmation.present?
  end

  def not_confirmed?
    !confirmed?
  end

end