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
      'Cancelled GRPO': 60,
      'AP Invoice Request Rejected': 80,
      'GRPO Request Rejected': 90,
      'GRPO Requested': 100,
      'Inward Completed': 110,
      'Cancelled AP Invoice': 120
  }

  enum rejection_reason: {
      'Mismatch: Supplier PO vs Supplier Invoice': 10,
      'Mismatch: HSN / SAC Code': 20,
      'Mismatch: Tax Rates': 30,
      'Mismatch: Supplier Billing or Shipping Address': 40,
      'Mismatch: Supplier GST Number': 50,
      'Mismatch: Supplier Name': 60,
      'Mismatch: Quantity': 70,
      'Mismatch: Unit Price': 80,
      'Mismatch: SKU / Description': 90,
      'Others': 100
  }



  scope :grpo_pending, -> { where(status: :'Pending GRPO') }
  scope :ap_invoice_pending, -> { where(status: :'Pending AP Invoice') }
  scope :ar_invoice_pending, -> { where(status: :'Pending AR Invoice') }
  scope :ar_invoice_generated, -> { where(status: :'Completed AR Invoice Request') }

  validates_presence_of :sales_order
  validates_presence_of :inquiry
  validates_numericality_of :ap_invoice_number, allow_blank: true
  validate :has_attachments?
  validate :grpo_number_valid?
  validate :presence_of_reason

  def grpo_number_valid?
    if self.grpo_number.present? && self.grpo_number <= 50000000
      errors.add(:grpo_number, 'must be 8 digits starting with 5')
    end
  end

  def has_attachments?
    if self.status != 'Cancelled' && !self.attachments.any?
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
    if ['In stock', 'Cancelled', 'GRPO Request Rejected', 'AP Invoice Request Rejected', 'Cancelled AR Invoice'].include? (status)
      self.status = status
    elsif self.ar_invoice_number.present?
      self.status = :'Completed AR Invoice Request'
    elsif self.ap_invoice_number.present?
      # self.status = :'Pending AR Invoice'
      self.status = :'Inward Completed'
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

  def rejection_reason_text
    if self.status == 'GRPO Request Rejected'
      self.rejection_reason == 'Others' ? self.other_rejection_reason : self.rejection_reason
    elsif status == 'AP Invoice Request Rejected'
      self.other_rejection_reason
    end
  end

  def display_reason(type = nil)
    if type == 'other'
      (['GRPO Request Rejected', 'AP Invoice Request Rejected'].include?(self.status) && self.grpo_rejection_reason == 'Others') ? '' : 'd-none'
    elsif type == 'cancellation'
      ['Cancelled GRPO','Cancelled AP Invoice'].include?(self.status) ? '' : 'd-none'
    elsif type == ('rejection')
      ['GRPO Request Rejected', 'AP Invoice Request Rejected'].include?(self.status) ? '' : 'd-none'
    end
  end

  def to_s
    [readable_status, "##{self.id}"].join(' ')
  end

  private

    def presence_of_reason
      # if ['GRPO Request Rejected', 'AP Invoice Request Rejected'].include?(status)
      if 'GRPO Request Rejected' == status
        if !rejection_reason.present?
          errors.add(:base, 'Please enter reason for rejection')
        elsif rejection_reason == 'Others' && !other_rejection_reason.present?
          errors.add(:base, 'Please enter reason for rejection')
        end
      elsif 'AP Invoice Request Rejected' == status
        if !other_rejection_reason.present?
          errors.add(:base, 'Please enter reason for rejection')
        end
      elsif  ['Cancelled GRPO','Cancelled AP Invoice'].include?(status)
        if !cancellation_reason.present?
          errors.add(:base, 'Please enter reason for cancellation')
        end
      end
    end
end
