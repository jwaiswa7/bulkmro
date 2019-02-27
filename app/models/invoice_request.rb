class InvoiceRequest < ApplicationRecord
  COMMENTS_CLASS = 'InvoiceRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, against: [:id, :grpo_number, :ap_invoice_number, :ar_invoice_number], associated_against: { sales_order: [:id, :order_number], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order
  belongs_to :inquiry
  belongs_to :purchase_order, required: false
  has_many :material_pickup_requests
  has_many_attached :attachments
  has_many :company_reviews, as: :rateable
  ratyrate_rateable 'CompanyReview'

  enum status: {
      'Pending GRPO': 10,
      'Pending AP Invoice': 20,
      'Pending AR Invoice': 30,
      'In stock': 70,
      'Completed AR Invoice Request': 40,
      'Cancelled AR Invoice': 50,
      'Cancelled': 60,
      'Mismatch: Supplier PO vs Supplier Invoice': 80,
      'Mismatch: HSN / SAC Code': 81,
      'Mismatch: Tax Rates': 82,
      'Mismatch: Supplier Billing or Shipping Address': 83,
      'Mismatch: Supplier GST Number': 84,
      'Mismatch: Supplier Name': 85,
      'Mismatch: Quantity': 86,
      'Mismatch: Unit Price': 87,
      'Mismatch: SKU / Description': 88,
      'Others': 89
  }



  scope :grpo_pending, -> { where(status: :'Pending GRPO') }
  scope :ap_invoice_pending, -> { where(status: :'Pending AP Invoice') }
  scope :ar_invoice_pending, -> { where(status: :'Pending AR Invoice') }
  scope :ar_invoice_generated, -> { where(status: :'Completed AR Invoice Request') }

  validates_presence_of :sales_order
  validates_presence_of :inquiry
  validates :ap_invoice_number, length: { is: 8 }, allow_blank: true
  validates_numericality_of :ap_invoice_number, allow_blank: true
  validate :has_attachments?
  validate :grpo_number_valid?

  def grpo_number_valid?
    if self.grpo_number.present? && self.grpo_number <= 50000000
      errors.add(:grpo_number, 'must be 8 digits starting with 5')
    end
  end

  def has_attachments?
    if !self.attachments.any?
      errors.add(:attachments, "must be present to create or update a #{self.readable_status}")
    end
  end

  validate :shipment_number_valid?

  def shipment_number_valid?
    if self.shipment_number.present? && self.shipment_number <= 30000000
      errors.add(:shipment_number, 'must be 8 digits starting with 3')
    end
  end

  with_options if: :"Pending AP Invoice?" do |invoice_request|
    invoice_request.validates_presence_of :grpo_number
  end

  with_options if: :"Completed AR Invoice Request?" do |invoice_request|
    invoice_request.validates_presence_of :ar_invoice_number
    invoice_request.validates :ar_invoice_number, length: { is: 8 }, allow_blank: true
    invoice_request.validates_numericality_of :ar_invoice_number, allow_blank: true
  end

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.status ||= :'Pending GRPO'
  end

  def update_status(status)
    if status == 'In stock' || status == 'Cancelled'
      self.status = status
    elsif self.ar_invoice_number.present?
      self.status = :'Completed AR Invoice Request'
    elsif self.ap_invoice_number.present?
      self.status = :'Pending AR Invoice'
    elsif self.grpo_number.present?
      self.status = :'Pending AP Invoice'
    else
      self.status = status
    end
  end

  def readable_status
    status = self.status
    if status.include? 'Pending'
      title_without_pending = status.remove('Pending')
      title = status.include?('GRPO') ? 'GRPO' : "#{title_without_pending}"
    elsif (status.include? 'Completed AR Invoice') || (status.include? 'Cancelled AR Invoice')
      title = status.gsub(status, 'AR Invoice')
    else
      title = 'GRPO'
    end
    "#{title} Request"
  end

  def grouped_status
    grouped_status = {}
    status_category = { 10 => 'Pending GRPO', 20 => 'Pending AP Invoice', 30 => 'Pending AR Invoice', 70 => 'In stock', 40 => 'Completed AR Invoice Request', 50 => 'Cancelled AR Invoice', 60 => 'Cancelled', 80 => 'Rejected' }
    status_category.each do |index, category|
      grouped_status[category] = InvoiceRequest.statuses.collect { |status, v|
        if v.between?(index, index + 9)
          status
        end}.compact
    end
    grouped_status
  end

  def to_s
    [readable_status, "##{self.id}"].join(' ')
  end
end
