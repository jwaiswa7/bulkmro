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
      :'Delivery Pending' => 30,
      :'AR Invoice Pending' => 40,
      :'AR Invoice Generated' => 50,
      :'AR Invoice Cancelled' => 60
  }

  scope :grpo_pending, -> {where(:status => :'GRPO Pending')}
  scope :ap_invoice_pending, -> {where(:status => :'AP Invoice Pending')}
  scope :delivery_pending, -> {where(:status => :'Delivery Pending')}
  scope :ar_invoice_pending, -> {where(:status => :'AR Invoice Pending')}
  scope :ar_invoice_generated, -> {where(:status => :'AR Invoice Generated')}

  after_initialize :set_defaults, :if => :new_record?

  validates_presence_of :sales_order
  validates_presence_of :inquiry

  validate :grpo_number_validation?

  with_options if: :"AP Invoice Pending?" do |invoice_request|
    invoice_request.validates_presence_of :grpo_number
  end

  with_options if: :"Delivery Pending?" do |invoice_request|
    invoice_request.validates_presence_of :grpo_number
    invoice_request.validates_presence_of :ap_invoice_number
  end

  with_options if: :"AR Invoice Generated?" do |invoice_request|
    invoice_request.validates_presence_of :ar_invoice_number
  end

  def set_defaults
    self.status = :'GRPO Pending'
  end

  def grpo_number_validation?
    if self.grpo_number.present? && self.grpo_number <= 50000000
      errors.add(:grpo_number, " must be 8 digits starting with 5")
    end
  end
end
