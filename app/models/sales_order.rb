class SalesOrder < ApplicationRecord
  COMMENTS_CLASS = 'InquiryComment'
  REJECTIONS_CLASS = 'SalesOrderRejection'
  APPROVALS_CLASS = 'SalesOrderApproval'

  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasComments
  include Mixins::CanBeSent
  include Mixins::CanBeSynced
  include Mixins::HasConvertedCalculations

  update_index('sales_orders#sales_order') {self}
  pg_search_scope :locate, :against => [:status, :id, :order_number], :associated_against => {:company => [:name], :inquiry => [:inquiry_number, :customer_po_number]}, :using => {:tsearch => {:prefix => true}}
  has_closure_tree({name_column: :to_s})

  has_one_attached :serialized_pdf

  belongs_to :sales_quote
  has_one :inquiry, :through => :sales_quote
  has_one :company, :through => :inquiry
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_many :rows, -> {joins(:inquiry_product).order('inquiry_products.sr_no ASC')}, class_name: 'SalesOrderRow', inverse_of: :sales_order, dependent: :destroy
  has_many :sales_order_rows, inverse_of: :sales_order
  accepts_nested_attributes_for :rows, reject_if: lambda {|attributes| (attributes['sales_quote_row_id'].blank? || attributes['quantity'].blank? || attributes['quantity'].to_f < 0) && attributes['id'].blank?}, allow_destroy: true
  has_many :sales_quote_rows, :through => :sales_quote
  has_many :shipments, class_name: 'SalesShipment', inverse_of: :sales_order
  has_many :invoices, class_name: 'SalesInvoice', inverse_of: :sales_order
  has_many :shipments, class_name: 'SalesShipment', inverse_of: :sales_order
  has_one :confirmation, :class_name => 'SalesOrderConfirmation', dependent: :destroy

  delegate :conversion_rate, to: :inquiry_currency
  attr_accessor :confirm_ord_values, :confirm_tax_rates, :confirm_hsn_codes, :confirm_billing_address, :confirm_shipping_address, :confirm_customer_po_no, :confirm_attachments
  delegate :inside_sales_owner, :outside_sales_owner, to: :inquiry, allow_nil: true

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status ||= :'Requested'
  end

  enum legacy_request_status: {
      :'Requested' => 10,
      :'SAP Approval Pending' => 20,
      :'Rejected' => 30,
      :'SAP Rejected' => 40,
      :'Cancelled' => 50,
      :'Approved' => 60,
      :'Order Deleted' => 70,
      :'Hold by Finance' => 80
  }, _prefix: true

  enum status: {
      :'Requested' => 10,
      :'SAP Approval Pending' => 20,
      :'Rejected' => 30,
      :'SAP Rejected' => 40,
      :'Cancelled' => 50,
      :'Approved' => 60,
      :'Order Deleted' => 70,
      :'Hold by Finance' => 80
  }, _prefix: true

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
      :'Cancelled by SAP' => 30,
      :'Short Close' => 31,
      :'Processing' => 32,
      :'Material Ready For Dispatch' => 33,
      :'Order Deleted' => 70
  }, _prefix: true

  scope :with_includes, -> {includes(:created_by, :updated_by, :inquiry)}

  def confirmed?
    self.confirmation.present?
  end

  def remote_approved?
    self.status == :'Approved'
  end

  def legacy?
    self.legacy_request_status.present?
  end

  def not_confirmed?
    !confirmed?
  end

  def syncable_identifiers
    [:draft_uid]
  end

  def update_index
    SalesOrdersIndex::SalesOrder.import([self.id])
  end

  def filename(include_extension: false)
    [
        ['order', id].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

end