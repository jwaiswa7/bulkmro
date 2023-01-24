class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments
  include Mixins::HasConvertedCalculations
  include Mixins::GetOverallDate

  update_index('po_requests#po_request') { self }
  update_index('purchase_orders#purchase_order') { purchase_order }
  update_index('customer_order_status_report#sales_order') { sales_order }
  scope :with_includes, -> {includes(:inquiry)}
  pg_search_scope :locate, against: [:id], associated_against: { sales_order: [:id, :order_number], inquiry: [:inquiry_number, :customer_po_number], supplier: [:name], account: [:name] }, using: { tsearch: { prefix: true } }
  belongs_to :sales_order, required: false
  belongs_to :inquiry
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  has_many :rows, class_name: 'PoRequestRow', inverse_of: :po_request, dependent: :destroy
  accepts_nested_attributes_for :rows, allow_destroy: true
  belongs_to :bill_to, class_name: 'Warehouse', foreign_key: :bill_to_id
  belongs_to :ship_to, class_name: 'Warehouse', foreign_key: :ship_to_id
  has_one :account, through: :inquiry

  belongs_to :bill_from, -> (record) { where(company_id: record.supplier.id) }, class_name: 'Address', foreign_key: :bill_from_id
  belongs_to :ship_from, -> (record) { where(company_id: record.supplier.id) }, class_name: 'Address', foreign_key: :ship_from_id
  belongs_to :contact, required: false

  belongs_to :purchase_order, required: false
  has_one :payment_request, required: false
  belongs_to :payment_option, required: false
  has_many_attached :attachments
  has_many :company_reviews, as: :rateable
  ratyrate_rateable 'CompanyReview'

  attr_accessor :opportunity_type, :customer_committed_date, :supplier_committed_date, :blobs, :common_lead_date

  belongs_to :requested_by, class_name: 'Overseer', foreign_key: 'requested_by_id', required: false
  belongs_to :approved_by, class_name: 'Overseer', foreign_key: 'approved_by_id', required: false
  belongs_to :company, required: false

  delegate :default_billing_address, :default_shipping_address, to: :supplier
  enum status: {
      'Supplier PO: Request Pending': 10,
      'Supplier PO: Created Not Sent': 20,
      'Cancelled': 30,
      'Supplier PO Request Rejected': 40,
      'Supplier PO: Amendment Pending': 50,
      'Supplier PO: Amended': 70,
      'Supplier PO Sent': 60
  }

  enum email_status: {
    'Supplier PO: Not Sent to Supplier': 10,
    'Supplier PO: Sent to Supplier': 20
  }

  enum supplier_po_type: {
      'Regular': 10,
      'Route Through': 20,
      'Drop Ship': 30
  }

  enum rejection_reason: {
      'Not Found: Supplier in SAP': 10,
      'Not Found: Supplier GST Number': 20,
      'Not Found: Supplier Address': 30,
      'Mismatch: HSN / SAC Code': 40,
      'Mismatch: Tax Rates': 50,
      'Mismatch: Supplier Billing or Shipping Address': 60,
      'Mismatch: Supplier GST Number': 70,
      'Others': 80
  }

  enum cancellation_reason: {
    'Change in payment term': 1,
    'Change in Inquiry': 2,
    'Change in quantity': 3,
    'Change in HSN/SAC': 4,
    'Change in Supplier': 5,
    'Change in Bill and Ship Address': 6,
    'Change in Tax Rate': 7,
    'Change in Unit Price': 8,
    'Customer PO amended': 9,
    'Customer PO cancelled': 10,
    'Supplier refused to deliver': 11,
    'Other': 12
  }

  enum po_request_type: {
      'Supplier': 10,
      'Stock': 20
  }

  enum stock_status: {
      'Stock Requested': 10,
      'Stock Rejected': 20,
      'Stock Supplier PO Created': 30,
      'Supplier Stock PO: Amendment Pending': 40,
      'Supplier Stock PO: Amended': 50
  }, _prefix: true

  enum transport_mode: {
      'Road': 1,
      'Air': 2,
      'Sea': 3
  }

  enum delivery_type: {
      'EXW': 10,
      'FOB': 20,
      'CIF': 30,
      'CFR': 40,
      'DAP': 50,
      'Door Delivery': 60,
      'FCA Mumbai': 70,
      'CIP': 80,
      'CIP Mumbai Airport': 100
  }

  scope :pending_and_rejected, -> { where(status: [:'Supplier PO: Request Pending', :'Supplier PO Request Rejected', :'Supplier PO: Amendment Pending']) }
  scope :handled, -> { where.not(status: [:'Supplier PO: Request Pending', :'Cancelled', :'Supplier PO: Amendment Pending']) }
  scope :not_cancelled, -> { where.not(status: [:'Cancelled']) }
  scope :cancelled, -> { where(status: [:'Cancelled']) }
  scope :can_amend, -> { where(status: [:'Supplier PO: Created Not Sent']) }
  scope :under_amend, -> { where(status: [:'Supplier PO: Amendment Pending']) }
  scope :amended, -> { where(status: [:'Supplier PO: Amended']) }
  scope :amended_and_sent, -> { where(status: [:'Supplier PO: Amended', :'Supplier PO Sent']) }
  scope :pending_stock_po, -> { where(stock_status: [:'Stock Requested']) }
  scope :completed_stock_po, -> { where(stock_status: [:'Stock Supplier PO Created']) }
  scope :stock_po, -> { where(stock_status: [:'Stock Requested', :'Stock Rejected', :'Stock Supplier PO Created', 'Supplier Stock PO: Amendment Pending', 'Supplier Stock PO: Amended']) }
  scope :stock_amend_request, -> { where(stock_status: ['Supplier Stock PO: Amendment Pending', 'Supplier Stock PO: Amended']) }

  validate :purchase_order_created?
  validates_uniqueness_of :purchase_order, if: -> { purchase_order.present? && !is_legacy }
  validate :update_reason_for_status_change?

  after_initialize :set_defaults, if: :new_record?
  after_save :update_po_index

  def purchase_order_created?
    if self.status == 'Supplier PO: Created Not Sent' && self.purchase_order.blank?
      errors.add(:purchase_order, ' number is mandatory')
    end
  end

  after_initialize :set_defaults, if: :new_record?

  def update_po_index
    if purchase_order.present?
      PurchaseOrdersIndex::PurchaseOrder.import([self.purchase_order.id])
    elsif self.saved_change_to_status? && self.status == 'Cancelled' && self.purchase_order_id_before_last_save.present?
      PurchaseOrdersIndex::PurchaseOrder.import([self.purchase_order_id_before_last_save])
    end
  end

  def update_reason_for_status_change?
    if self.po_request_type == 'Regular'
      if (self.status == 'Cancelled' && self.cancellation_reason.blank?) || (self.status == 'Supplier PO Request Rejected' && self.rejection_reason.blank?)
        errors.add(:base, "Provide a reason to change the status to #{self.status}")
      end
    elsif self.po_request_type == 'Stock'
      if self.stock_status == 'Stock Rejected' && self.rejection_reason.blank?
        errors.add(:base, "Provide a reason to change the stock_status to #{self.stock_status} in message section")
      end
    end
  end

  def set_defaults
    self.status ||= :'Supplier PO: Request Pending' if self.po_request_type == 'Regular'
    self.stock_status ||= :'Stock Requested' if self.po_request_type == 'Stock'
    #     self.commercial_terms_and_conditions ||= [
    #         '1. Cost does not include any additional certification if required as per Indian regulations.',
    #         '2. Any errors in quotation including HSN codes, GST Tax rates must be notified before placing order.',
    #         '3. Order once placed cannot be changed.',
    #         '4. BulkMRO does not accept any financial penalties for late deliveries.',
    #         '5. Warranties are applicable as per OEM\'s Standard warranty only.'
    #     ].join("\r\n")
  end

  def amending?
    status == 'Supplier PO: Amendment Pending'
  end

  def not_amending?
    status != 'Supplier PO: Amendment Pending'
  end

  def not_cancelled?
    status != 'Cancelled'
  end

  def selling_price
    rows.sum(&:converted_total_selling_price).round(2)
  end

  def buying_price
    rows.sum(&:converted_total_buying_price).round(2)
  end

  def po_margin
    (self.selling_price - self.buying_price).round(2) if self.selling_price > 0
  end

  def po_margin_percentage
    (((self.selling_price - self.buying_price) / self.selling_price) * 100).round(2) if self.selling_price > 0
  end

  def show_supplier_delivery_date
    get_overall_date(self)
  end

  def readable_status
    title = ''
    if self.status == 'Supplier PO: Request Pending'
      title = 'Pending'
    elsif self.status == 'Supplier PO: Created Not Sent'
      title = 'Completed'
    end
    "#{title} PO Request"
  end

  def to_s
    [readable_status, " ##{self.id}"].join
  end

  def check_material_status?
    if  (self.purchase_order.present? && self.purchase_order.material_status != 'Material Delivered') || (self.purchase_order.present? && self.purchase_order.invoice_request.present? && self.purchase_order.invoice_request.status == 'GRPO Request Rejected')
      true
    else
      false
    end
  end

  def calculated_total_with_tax
    each_row_total_with_tax = rows.map {|row| (row.total_incl_tax.to_f || 0)}
    if each_row_total_with_tax.present?
      (each_row_total_with_tax.compact.sum.round(2)).to_f
    else
      0
    end
  end

end
