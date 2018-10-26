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
  #pg_search_scope :locate, :against => [], :associated_against => {:company => [:name], :inquiry => [:inquiry_number, :customer_po_number]}, :using => {:tsearch => {:prefix => true}}
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

  def filename(include_extension: false)
    [
        ['order', id].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def self.to_csv
    start_at = 'Fri, 19 Oct 2018'.to_date
    end_at = Date.today
    desired_columns = ["order_number", "order_date", "quote_number", "quote_type", "opportunity_type", "invoice_number", "inside_sales", "outside_sales", "company_alias", "company_name", "bill_to_name", "ship_to_name", "customer_po_number", "grand_total (Exc. Tax)", "grand_total (Inc.Tax)", "buying_cost (Exc. Tax)", "margin (Exc. tax)", "status"]

    objects = [ ]
    SalesOrder.status_Approved.where(:created_at => start_at..end_at).each do |so|
      inquiry = so.inquiry
      order_number = so.order_number
      order_date = so.created_at.to_date.to_s
      quote_number = inquiry.inquiry_number
      quote_type =  inquiry.quote_category
      opportunity_type = inquiry.opportunity_type
      invoice_number = so.invoices.pluck(:invoice_number).join(",")
      inside_sales = so.inside_sales_owner.to_s
      outside_sales = so.outside_sales_owner.to_s
      company_alias = inquiry.account.name
      company_name = inquiry.company.name
      bill_to_name = inquiry.contact.full_name
      ship_to_name = inquiry.contact.full_name
      customer_po_number = inquiry.customer_po_number
      gt_exc = ('%.2f' % so.calculated_total)
      gt_inc = ('%.2f' % so.calculated_total_with_tax)
      buying_cost_exc = ('%.2f' % so.calculated_total_cost)
      margin_exc = ('%.2f' % so.calculated_total_margin)
      status = so.remote_status

      o = [order_number,order_date,quote_number,quote_type,opportunity_type,invoice_number,inside_sales,outside_sales,company_alias,company_name,bill_to_name,ship_to_name,customer_po_number,gt_exc,gt_inc,buying_cost_exc,margin_exc,status]
      objects.push(o)
    end

    CSV.generate(write_headers: true, headers: desired_columns) do |csv|
      objects.each do |so|
        csv << so
      end
    end
  end

end