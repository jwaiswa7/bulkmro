# frozen_string_literal: true

class InvoiceRequest < ApplicationRecord
  COMMENTS_CLASS = 'InvoiceRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, against: %i[id grpo_number ap_invoice_number ar_invoice_number], associated_against: { sales_order: %i[id order_number], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order
  belongs_to :inquiry
  belongs_to :purchase_order, required: false
  has_many_attached :attachments

  enum status: {
    'Pending GRPO': 10,
    'Pending AP Invoice': 20,
    'Pending AR Invoice': 30,
    'In stock': 70,
    'Completed AR Invoice Request': 40,
    'Cancelled AR Invoice': 50,
    'Cancelled': 60
  }

  scope :grpo_pending, -> { where(status: :'Pending GRPO') }
  scope :ap_invoice_pending, -> { where(status: :'Pending AP Invoice') }
  scope :ar_invoice_pending, -> { where(status: :'Pending AR Invoice') }
  scope :ar_invoice_generated, -> { where(status: :'Completed AR Invoice Request') }

  validates_presence_of :sales_order
  validates_presence_of :inquiry
  validates :ap_invoice_number, length: { is: 8 }, allow_blank: true
  validates_numericality_of :ap_invoice_number, allow_blank: true

  validate :grpo_number_valid?

  def grpo_number_valid?
    if grpo_number.present? && grpo_number <= 50_000_000
      errors.add(:grpo_number, 'must be 8 digits starting with 5')
    end
  end

  validate :shipment_number_valid?

  def shipment_number_valid?
    if shipment_number.present? && shipment_number <= 30_000_000
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
    self.status = if status == 'In stock' || status == 'Cancelled'
      status
    elsif ar_invoice_number.present?
      :'Completed AR Invoice Request'
    elsif ap_invoice_number.present?
      :'Pending AR Invoice'
    elsif grpo_number.present?
      :'Pending AP Invoice'
    else
      status
    end
  end
end
