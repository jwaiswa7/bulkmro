class InvoiceRequest < ApplicationRecord
  COMMENTS_CLASS = 'InvoiceRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id, :grpo_number, :ap_invoice_number, :ar_invoice_number], :associated_against => {:sales_order => [:id, :order_number], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :sales_order
  belongs_to :inquiry
  belongs_to :purchase_order, required: false
  has_many_attached :attachments

  enum status: {
      :'GRPO Pending' => 10,
      :'AP Invoice Pending' => 20,
      :'AR Invoice Pending' => 30,
      :'AR Invoice Generated' => 40,
      :'AR Invoice Cancelled' => 50
  }

  scope :grpo_pending, -> {where(:status => :'GRPO Pending')}
  scope :ap_invoice_pending, -> {where(:status => :'AP Invoice Pending')}
  scope :ar_invoice_pending, -> {where(:status => :'AR Invoice Pending')}
  scope :ar_invoice_generated, -> {where(:status => :'AR Invoice Generated')}

  validates_presence_of :sales_order
  validates_presence_of :inquiry

  validate :grpo_number_valid?
  def grpo_number_valid?
    if self.grpo_number.present? && self.grpo_number <= 50000000
      errors.add(:grpo_number, "must be 8 digits starting with 5")
    end
  end

  validate :shipment_number_valid?
  def shipment_number_valid?
    if self.shipment_number.present? && self.shipment_number <= 30000000
      errors.add(:shipment_number, "must be 8 digits starting with 3")
    end
  end

  with_options if: :"AP Invoice Pending?" do |invoice_request|
    invoice_request.validates_presence_of :grpo_number
  end

  with_options if: :"AR Invoice Generated?" do |invoice_request|
    invoice_request.validates_presence_of :ar_invoice_number
  end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.status = :'GRPO Pending'
  end
end
