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
  include DisplayHelper

  update_index('sales_orders#sales_order') { self }
  update_index('customer_order_status_report#sales_order') { self }

  pg_search_scope :locate, against: [:status, :id, :order_number], associated_against: {company: [:name], inquiry: [:inquiry_number, :customer_po_number]}, using: {tsearch: {prefix: true}}
  has_closure_tree(name_column: :to_s)

  has_one_attached :serialized_pdf
  has_many_attached :revised_committed_delivery_attachments

  belongs_to :sales_quote

  has_one :inquiry, through: :sales_quote
  has_one :payment_option, through: :inquiry
  has_one :company, through: :inquiry
  has_one :account, through: :company
  has_one :inquiry_currency, through: :inquiry
  has_one :currency, through: :inquiry_currency
  has_many :rows, -> { joins(:inquiry_product).order('inquiry_products.sr_no ASC') }, class_name: 'SalesOrderRow', inverse_of: :sales_order, dependent: :destroy
  has_many :sales_order_rows, inverse_of: :sales_order
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| (attributes['sales_quote_row_id'].blank? || attributes['quantity'].blank? || attributes['quantity'].to_f < 0) && attributes['id'].blank? }, allow_destroy: true
  has_many :sales_quote_rows, through: :sales_quote
  has_many :inquiry_product_suppliers, through: :sales_quote_rows
  has_many :products, through: :rows
  has_many :categories, through: :products
  has_many :shipments, class_name: 'SalesShipment', inverse_of: :sales_order
  has_many :invoices, class_name: 'SalesInvoice', inverse_of: :sales_order
  has_many :shipments, class_name: 'SalesShipment', inverse_of: :sales_order
  has_many :inward_dispatches
  has_many :outward_dispatches


  has_one :confirmation, class_name: 'SalesOrderConfirmation', dependent: :destroy
  has_many :po_requests, inverse_of: :sales_order, dependent: :destroy
  accepts_nested_attributes_for :po_requests, allow_destroy: true
  has_many :invoice_requests
  has_many :ar_invoice_requests
  has_many :ar_invoice_request_rows, through: :ar_invoice_request
  has_many :email_messages
  belongs_to :billing_address, class_name: 'Address', dependent: :destroy, required: false
  belongs_to :shipping_address, class_name: 'Address', dependent: :destroy, required: false

  delegate :conversion_rate, to: :inquiry_currency
  attr_accessor :confirm_ord_values, :confirm_tax_rates, :confirm_hsn_codes, :confirm_billing_address, :confirm_shipping_address, :confirm_purchase_order_number, :confirm_payment_terms, :confirm_tax_types, :confirm_customer_po_no, :confirm_attachments, :confirm_billing_warehouse, :confirm_shipping_warehouse
  delegate :inside_sales_owner, :outside_sales_owner, :inside_sales_owner_id, :outside_sales_owner_id, :opportunity_type, :customer_committed_date, to: :inquiry, allow_nil: true
  delegate :currency_sign, to: :sales_quote

  # validates_length_of :rows, minimum: 1, :message => "must have at least one sales order row", :if => :not_legacy?

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    # self.status ||= :'Requested'
  end

  enum effective_status: {
      'Processing': 1,
      'Partially Shipped': 2,
      'Partially Invoiced': 3,
      'Partially Delivered: GRN Pending': 4,
      'Partially Delivered: GRN Received': 5,
      'Shipped': 6,
      'Invoiced': 7,
      'Delivered: GRN Pending': 8,
      'Delivered: GRN Received': 9,
      'Partial Payment Received': 10,
      'Full Payment Received': 11,
      'Short Closed': 12,
      'Material Ready For Dispatch': 13,
      'Cancelled': 14,
      'Closed': 15
  }, _prefix: true

  enum legacy_request_status: {
      'Requested': 10,
      'SAP Approval Pending': 20,
      'Rejected': 30,
      'SAP Rejected': 40,
      'Cancelled': 50,
      'Approved': 60,
      'Order Deleted': 70,
      'Hold by Finance': 80
  }, _prefix: true

  enum status: {
      'Requested': 10,
      'Accounts Approval Pending': 20,
      'Rejected': 30,
      'SAP Rejected': 40,
      'Cancelled': 50,
      'Approved': 60,
      'Order Deleted': 70,
      'Hold by Finance': 80,
      'CO': 90
  }, _prefix: true

  enum remote_status: {
      'Supplier PO: Request Pending': 17,
      'Supplier PO: Partially Created': 18,
      'Partially Shipped': 19,
      'Partially Invoiced': 20,
      'Partially Delivered: GRN Pending': 21,
      'Partially Delivered: GRN Received': 22,
      'Supplier PO: Created': 23,
      'Shipped': 24,
      'Invoiced': 25,
      'Delivered: GRN Pending': 26,
      'Delivered: GRN Received': 27,
      'Partial Payment Received': 28,
      'Payment Received (Closed)': 29,
      'Cancelled by SAP': 30,
      'Short Close': 31,
      'Processing': 32,
      'Material Ready For Dispatch': 33,
      'Order Deleted': 70
  }, _prefix: true

  enum reject_reason: {
      "Wrong PO Number": 'Wrong PO Number',
      "Wrong Payment Terms": 'Wrong Payment Terms',
      "Wrong Billing Warehouse": 'Wrong Billing Warehouse',
      "Wrong Shipping Warehouse": 'Wrong Shipping Warehouse',
      "Wrong Billing Address": 'Wrong Billing Address',
      "Wrong Shipping Address": 'Wrong Shipping Address',
      "Wrong Attachments": 'Wrong Attachments',
      "Wrong HSN Codes": 'Wrong HSN Codes',
      "Wrong Tax Rates": 'Wrong Tax Rates',
      "Wrong Tax Types": 'Wrong Tax Types',
      "Wrong Order Values": 'Wrong Order Values'
  }

  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }
  scope :remote_approved, -> { where('(((sales_orders.status = ? OR sales_orders.status = ?) AND sales_orders.remote_status != ?) OR sales_orders.legacy_request_status = ?) AND sales_orders.status != ?', SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'CO'], SalesOrder.remote_statuses[:'Cancelled by SAP'], SalesOrder.legacy_request_statuses['Approved'], SalesOrder.statuses[:'Cancelled']) }
  scope :accounts_approval_pending, -> { where(status: 'Accounts Approval Pending').where("created_at >= '2019-07-18'") }
  scope :under_process, -> { where(status: [:'Approved', :'Accounts Approval Pending', 'Requested']) }
  scope :without_cancelled, -> { where.not(status: 'Cancelled') }

  def confirmed?
    self.confirmation.present?
  end

  def remote_approved?
    self.status == 'Approved' || self.legacy_request_status == 'Approved' || self.status == 'CO'
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

  def order_status
    self.status || self.legacy_request_status
  end

  def update_index
    SalesOrdersIndex::SalesOrder.import([self.id])
  end

  def effective_customer_status
    if self.remote_status.blank?
      return 'Processing'
    end

    case self.remote_status.to_sym
    when :'Supplier PO: Request Pending'
      'Processing'
    when :'Supplier PO: Partially Created'
      'Processing'
    when :'Partially Shipped'
      'Partially Shipped'
    when :'Partially Invoiced'
      'Partially Invoiced'
    when :'Partially Delivered: GRN Pending'
      'Partially Delivered: GRN Pending'
    when :'Partially Delivered: GRN Received'
      'Partially Delivered: GRN Received'
    when :'Supplier PO: Created'
      'Processing'
    when :'Shipped'
      'Shipped'
    when :'Invoiced'
      'Invoiced'
    when :'Delivered: GRN Pending'
      'Delivered: GRN Pending'
    when :'Delivered: GRN Received'
      'Delivered: GRN Received'
    when :'Partial Payment Received'
      'Partial Payment Received'
    when :'Payment Received (Closed)'
      'Full Payment Received'
    when :'Cancelled by SAP'
      'Processing'
    when :'Short Close'
      'Short Closed'
    when :'Processing'
      'Processing'
    when :'Material Ready For Dispatch'
      'Material Ready For Dispatch'
    when :'Order Deleted'
      'Cancelled'
    when :'Order Lost'
      'Closed'
    end
  end


  def serialized_billing_address
    self.billing_address.present? ? self.billing_address : self.inquiry.billing_address
  end

  def serialized_shipping_address
    self.shipping_address.present? ? self.shipping_address : self.inquiry.shipping_address
  end

  def filename(include_extension: false)
    [
        ['order', id].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def to_s
    ['#', order_number].join if order_number.present?
  end

  def total_quantities
    self.rows.pluck(:quantity).inject(0) { |sum, x| sum + x }
  end

  def is_not_requested?(record)
    if record.status != 'Requested'
      true
    else
      false
    end
  end

  def has_purchase_order_request
    self.po_requests.present?
  end

  def not_invoiced_value(status)
    self.order_total
  end

  def get_draft_sap_sync
    if self.approval.present? && self.draft_sync_date.present?
      self.draft_sync_date
    elsif self.approval.present?
      draft_remote_request = RemoteRequest.where(subject_type: 'SalesOrder', subject_id: self.id, status: 'success').first
      if draft_remote_request.present?
        self.update_attributes!(draft_sync_date: draft_remote_request.created_at)
        self.draft_sync_date
      end
    end
  end

  def calculate_time_delay
    if self.inquiry.present? && self.invoices.present? && self.invoices.last.delivery_date.present?
      if self.revised_committed_delivery_date.present?
        ((self.invoices.last.delivery_date.to_time.to_i - self.revised_committed_delivery_date.to_time.to_i) / 60.0).ceil.abs
      elsif self.inquiry.customer_committed_date.present?
        ((self.invoices.last.delivery_date.to_time.to_i - self.inquiry.customer_committed_date.to_time.to_i) / 60.0).ceil.abs
      end
    end
  end

  def set_so_status_value
    self.remote_status.present? ? SalesOrder.remote_statuses[self.remote_status.to_sym] : 32
  end

  # bible data methods

  def bible_total_quote_value
    total_quote_value = 0
    sales_quotes_ids = []
    BibleSalesOrder.where(order_number: self.order_number).each do |bso|
      sales_order = SalesOrder.find_by_order_number(bso.order_number)
      if sales_order.present?
        if !sales_quotes_ids.include? sales_order.sales_quote.id
          total_quote_value += sales_order.sales_quote.calculated_total
          sales_quotes_ids << sales_order.sales_quote.id
        end
      end
    end

    if self.inquiry.final_sales_quote.present? && !(sales_quotes_ids.include? self.inquiry.final_sales_quote.id)
      total_quote_value += self.inquiry.final_sales_quote.calculated_total
    end

    total_quote_value
  end

  def unique_skus_in_order
    bible_orders = BibleSalesOrder.where(order_number: self.order_number)
    bible_orders.map { |bo| bo.metadata.map { |m| m['sku'] } }.flatten.compact.uniq.count
  end

  def bible_sales_invoices
    invoice_numbers = self.invoices.pluck(:invoice_number) if self.invoices.present?
    BibleInvoice.where(invoice_number: invoice_numbers)
  end

  def bible_margin_percentage
    BibleSalesOrder.where(order_number: self.order_number).pluck(:overall_margin_percentage).sum
  end

  def bible_sales_order_total
    BibleSalesOrder.where(order_number: self.order_number).pluck(:order_total).sum
  end

  def bible_sales_invoice_total
    invoice_numbers = self.invoices.pluck(:invoice_number) if self.invoices.present?
    BibleInvoice.where(invoice_number: invoice_numbers).pluck(:invoice_total).sum
  end

  def bible_assumed_margin
    BibleSalesOrder.where(order_number: self.order_number).pluck(:total_margin).sum
  end

  def bible_actual_margin
    invoice_numbers = self.invoices.pluck(:invoice_number) if self.invoices.present?
    BibleInvoice.where(invoice_number: invoice_numbers).pluck(:total_margin).sum
  end

  def bible_actual_margin_percentage
    invoice_numbers = self.invoices.pluck(:invoice_number) if self.invoices.present?
    BibleInvoice.where(invoice_number: invoice_numbers).pluck(:overall_margin_percentage).sum
  end

  def get_invoiced_qty
    self.invoices.sum(&:total_quantity).to_i
  end

  def total_qty
    self.rows.sum(:quantity).to_i
  end

  def is_invoices_cancelled
    self.invoices.pluck(:status).all?('Cancelled')
  end
end
