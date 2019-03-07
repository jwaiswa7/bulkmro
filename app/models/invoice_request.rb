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
      'AP Invoice Request Rejected': 80,
      'GRPO Request Rejected': 90,
      'GRPO Requested': 100,
      'Inward Completed': 110,
      'Cancelled AP Invoice': 120,
      'Cancelled GRPO': 130
  }

  enum grpo_rejection_reason: {
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
    p self.id
    p self.status
    p (self.status != 'Cancelled GRPO' || self.status != 'Cancelled AP Invoice')
    if !['Cancelled GRPO', 'Cancelled AP Invoice'].include?(self.status) && !self.attachments.any?
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
    if ['In stock', 'Cancelled GRPO', 'GRPO Request Rejected', 'AP Invoice Request Rejected', 'Cancelled AP Invoice'].include? (status)
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
      self.grpo_rejection_reason == 'Others' ? self.grpo_other_rejection_reason : self.grpo_rejection_reason
    elsif status == 'AP Invoice Request Rejected'
      self.ap_rejection_reason
    end
  end

  def cancellation_reason_text
    if self.status == 'Cancelled GRPO'
      self.grpo_cancellation_reason
    elsif self.status == 'Cancelled AP Invoice'
      self.ap_cancellation_reason
    end
  end

  def display_reason(type = nil)
    # If status is cancelled then also all rejection as well as other cacellation display on first load of form to avoid that ui helper written
    case type
    when 'other'
      (('GRPO Request Rejected' == self.status) && self.grpo_rejection_reason == 'Others') ? '' : 'd-none'
    when 'ap_rejection'
      ('AP Invoice Request Rejected' == self.status) ? '' : 'd-none'
    when 'grpo_rejection'
      ('GRPO Request Rejected' == self.status) ? '' : 'd-none'
    when 'grpo_cancellation'
      ('Cancelled GRPO' == self.status) ? '' : 'd-none'
    when 'ap_cancellation'
      ('Cancelled AP Invoice' == self.status) ? '' : 'd-none'
    end
  end

  def to_s
    [readable_status, "##{self.id}"].join(' ')
  end

  private

    def presence_of_reason
      case status
      when 'GRPO Request Rejected'
        if !grpo_rejection_reason.present?
          errors.add(:base, 'Please enter reason for GRPO request rejection')
        elsif grpo_rejection_reason == 'Others' && !grpo_other_rejection_reason.present?
          errors.add(:base, 'Please enter reason for GRPO request rejection')
        end
      when 'AP Invoice Request Rejected'
        if !ap_rejection_reason.present?
          errors.add(:base, 'Please enter reason for AP Invoice rejection')
        end
      when 'Cancelled GRPO'
        if !grpo_cancellation_reason.present?
          errors.add(:base, 'Please enter reason for GRPO request cancellation')
        end
      when 'Cancelled AP Invoice'
        if !ap_cancellation_reason.present?
          errors.add(:base, 'Please enter reason for AP request cancellation')
        end
      else
      end
    end
end
