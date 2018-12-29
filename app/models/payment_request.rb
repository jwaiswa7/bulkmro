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
      :'Complete: Payment Pending' => 11,
      :'Rejected: Payment' => 30,
      :'Supplier Info: Bank Details Missing' => 31,
      :'Supplier Info: Bank Details Incorrect' => 32,
      :'Order Info: Material not Ready' => 33,
      :'Supplier Info: PI mismatch' => 34,
      :'Payment on Hold' => 40,
      :'Order Info: Low Margin' => 41,
      :'Other Issues' => 42,
      :'Partial: Payment Made' => 50,
      :'Complete: Payment Made' => 51,
      :'Refund' => 70,
      :'Excess Payment Made' => 71,
      :'Supplier cannot fulfill PO' => 72,
      :'Material Rejected' => 73
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

  enum request_owner: {
      :'Logistics' => 10,
      :'Accounts' => 20
  }

  scope :Pending, -> {where(status:['Partial: Payment Pending','Complete: Payment Pending'])}
  scope :Completed, -> {where(:status => :'Complete: Payment Made')}
  scope :Rejected, -> {where(status: ['Rejected: Payment','Supplier Info: Bank Details Missing','Supplier Info: Bank Details Incorrect','Order Info: Material not Ready','Supplier Info: PI mismatch'])}
  scope :Logistics, -> {where(status:['Partial: Payment Pending','Complete: Payment Pending'], request_owner:['Logistics','Accounts'])}
  scope :Accounts, -> {where(status:['Partial: Payment Pending','Complete: Payment Pending'], request_owner: 'Accounts')}

  validates_presence_of :inquiry
  validates_presence_of :cheque_date, if: Proc.new { |payment_request| payment_request.payment_type == 'Cheque' }
  # with_options if: :"Completed?" do |payment_request|
  #   payment_request.validates_presence_of :payment_type
  # end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.status ||= :'Complete: Payment Pending'
    self.request_owner ||= :'Logistics'
  end

  def update_status!
    if self.utr_number.present?
      self.status = :'Completed'
    else
      self.status = :'Pending'
    end
  end

  def grouped_status
    grouped_status = {}
    status_category = { 10 => 'Pending', 30 =>'Rejected', 40 => 'Payment on Hold', 50 => 'Completed', 70 => 'Refund'}
    status_category.each do |index, category|
      grouped_status[category] = PaymentRequest.statuses.collect{|status,v|;if v.between?(index, index+9);status;end}.compact
    end
    grouped_status
  end
end
