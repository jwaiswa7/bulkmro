class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments
  include Mixins::HasConvertedCalculations
  include Mixins::GetOverallDate

  pg_search_scope :locate, against: [:id], associated_against: { sales_order: [:id, :order_number], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order
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

  attr_accessor :opportunity_type, :customer_committed_date, :blobs

  enum status: {
      'Requested': 10,
      'PO Created': 20,
      'Cancelled': 30,
      'Rejected': 40,
      'Amend': 50,
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

  scope :pending_and_rejected, -> { where(status: [:'Requested', :'Rejected', :'Amend']) }
  scope :handled, -> { where.not(status: [:'Requested', :'Cancelled', :'Amend']) }
  scope :not_cancelled, -> { where.not(status: [:'Cancelled']) }
  scope :cancelled, -> { where(status: [:'Cancelled']) }
  scope :can_amend, -> { where(status: [:'PO Created']) }
  scope :amended, -> { where(status: [:'Amend']) }

  validate :purchase_order_created?
  validates_uniqueness_of :purchase_order, if: -> { purchase_order.present? && !is_legacy }
  validate :update_reason_for_status_change?

  after_initialize :set_defaults, if: :new_record?
  after_save :update_po_index, if: -> { purchase_order.present? }

  def purchase_order_created?
    if self.status == 'PO Created' && self.purchase_order.blank?
      errors.add(:purchase_order, ' number is mandatory')
    end
  end

  after_initialize :set_defaults, if: :new_record?

  def update_po_index
    PurchaseOrdersIndex::PurchaseOrder.import([self.purchase_order.id])
  end

  def update_reason_for_status_change?
    if (self.status == 'Cancelled' && self.cancellation_reason.blank?) || (self.status == 'Rejected' && self.rejection_reason.blank?)
      errors.add(:base, "Provide a reason to change the status to #{self.status} in message section")
    end
  end

  def set_defaults
    self.status ||= :'Requested'
  end

  def amending?
    status == 'Amend'
  end

  def not_amending?
    status != 'Amend'
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
    (((self.buying_price - self.selling_price) / self.buying_price) * 100).round(2) if self.buying_price > 0
  end

  def show_supplier_delivery_date
    get_overall_date1(self)
  end

  def readable_status
    title = ''
    if self.status == 'Requested'
      title = 'Pending'
    elsif self.status == 'PO Created'
      title = 'Completed'
    end
    "#{title} PO Request"
  end

  def to_s
    [readable_status, " ##{self.id}"].join
  end
end
