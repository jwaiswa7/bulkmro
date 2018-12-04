class InvoiceRequest < ApplicationRecord
  COMMENTS_CLASS = 'InvoiceRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id], :associated_against => {:sales_order => [:id, :order_number], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

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

end
