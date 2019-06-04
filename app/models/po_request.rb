class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments
  include Mixins::HasConvertedCalculations
  include Mixins::GetOverallDate

  update_index('purchase_orders#purchase_order') { purchase_order }
  update_index('customer_order_status_report#sales_order') { sales_order }

  pg_search_scope :locate, against: [:id], associated_against: { sales_order: [:id, :order_number], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order, required: false
  belongs_to :inquiry
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  has_many :rows, class_name: 'PoRequestRow', inverse_of: :po_request, dependent: :destroy
  accepts_nested_attributes_for :rows, allow_destroy: true
  belongs_to :bill_to, class_name: 'Warehouse', foreign_key: :bill_to_id
  belongs_to :ship_to, class_name: 'Warehouse', foreign_key: :ship_to_id

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

  enum status: {
      'Supplier PO: Request Pending': 10,
      'Supplier PO: Created Not Sent': 20,
      'Cancelled': 30,
      'Supplier PO Request Rejected': 40,
      'Supplier PO: Amendment Pending': 50,
      'Supplier PO: Amended': 70,
      'Supplier PO Sent': 60
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

  enum po_request_type: {
      'Supplier': 10,
      'Stock': 20
  }

  enum stock_status: {
      'Stock Requested': 10,
      'Stock Rejected': 20,
      'Stock Supplier PO Created': 30
  }

  scope :pending_and_rejected, -> { where(status: [:'Supplier PO: Request Pending', :'Supplier PO Request Rejected', :'Supplier PO: Amendment Pending']) }
  scope :handled, -> { where.not(status: [:'Supplier PO: Request Pending', :'Cancelled', :'Supplier PO: Amendment Pending']) }
  scope :not_cancelled, -> { where.not(status: [:'Cancelled']) }
  scope :cancelled, -> { where(status: [:'Cancelled']) }
  scope :can_amend, -> { where(status: [:'Supplier PO: Created Not Sent']) }
  scope :under_amend, -> { where(status: [:'Supplier PO: Amendment Pending']) }
  scope :amended, -> { where(status: [:'Supplier PO: Amended']) }
  scope :pending_stock_po, -> { where(stock_status: [:'Stock Requested']) }
  scope :completed_stock_po, -> { where(stock_status: [:'Stock Supplier PO Created']) }
  scope :stock_po, -> { where(stock_status: [:'Stock Requested', :'Stock Rejected', :'Stock Supplier PO Created']) }

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
end
