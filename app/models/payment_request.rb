class PaymentRequest < ApplicationRecord
  COMMENTS_CLASS = 'PaymentRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id, :utr_number], :associated_against => {:po_request => [:id, :purchase_order_id], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :inquiry
  belongs_to :purchase_order
  belongs_to :po_request
  has_many_attached :attachments
  has_one :payment_option, :through => :purchase_order

  accepts_nested_attributes_for :inquiry

  enum status: {
      :'Partial: Payment Pending' => 10,
      :'Complete: Payment Pending' => 20,
      :'Rejected: Payment' => 30,
      :'Payment on Hold' => 40,
      :'Partial: Payment Made' => 50,
      :'Complete: Payment Made' => 60,
      :'Refund' => 70
  }

  enum payment_type: {
      :'Cheque' => 10,
      :'NEFT/RTGS' => 20
  }

  enum purpose_of_payment: {
      :'Advance' => 10,
      :'Material Ready' => 20,
      :'Payment Due' => 30
  }

  scope :Pending, -> {where(:status => :'Complete: Payment Pending')}
  scope :completed, -> {where(:status => :'Complete: Payment Made')}

  validates_presence_of :inquiry
  # with_options if: :"Completed?" do |payment_request|
  #   payment_request.validates_presence_of :payment_type
  # end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.status ||= :'Complete: Payment Pending'
  end

  def update_status!
    if self.utr_number.present?
      self.status = :'Completed'
    else
      self.status = :'Pending'
    end
  end
end
