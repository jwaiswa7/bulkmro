class PaymentRequest < ApplicationRecord
  COMMENTS_CLASS = 'PaymentRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, against: [:id], associated_against: { po_request: [:id, :purchase_order_id], inquiry: [:inquiry_number], purchase_order: [:po_number] }, using: { tsearch: { prefix: true } }

  belongs_to :inquiry
  belongs_to :purchase_order
  belongs_to :po_request
  has_many_attached :attachments
  has_one :payment_option, through: :purchase_order
  belongs_to :company_bank, required: false
  accepts_nested_attributes_for :inquiry
  has_many :transactions, class_name: 'PaymentRequestTransaction', dependent: :destroy
  accepts_nested_attributes_for :transactions, allow_destroy: true

  enum status: {
      'Payment Pending': 10,
      'Partial Payment Pending': 11,
      # :'Rejected: Payment' => 30,
      'Supplier Info: Bank Details Missing': 31,
      'Supplier Info: Bank Details Incorrect': 32,
      # :'Order Info: Material not Ready' => 33,
      'Supplier Info: PI mismatch': 34,
      'Rejected: Others': 35,
      # :'Payment on Hold' => 40,
      'Order Info: Low Margin': 41,
      'Payment on Hold: Others': 42,
      'Payment Made': 50,
      'Partial Payment Made': 51,
      # :'Refund' => 70,
      'Excess Payment Made': 71,
      'Supplier cannot fulfill PO': 72,
      'Material Rejected': 73,
      'Cancelled': 80
  }

  enum payment_type: {
      'Cheque': 10,
      'NEFT/RTGS': 20
  }

  enum purpose_of_payment: {
      'Advance - On issue of PO': 10,
      'Advance - Material Ready for dispatch': 20,
      'Credit': 30
  }

  enum request_owner: {
      'Logistics': 10,
      'Accounts': 20
  }

  scope :Pending, -> { where(status: [10, 11]) }
  scope :Completed, -> { where(status: 50) }
  scope :Rejected, -> { where(status: ['Supplier Info: Bank Details Missing', 'Supplier Info: Bank Details Incorrect', 'Supplier Info: PI mismatch']) }
  scope :Logistics, -> { where(status: [10, 11], request_owner: ['Logistics', 'Accounts']) }
  scope :Accounts, -> { where(status: [10, 11], request_owner: 'Accounts') }

  validates_presence_of :inquiry
  with_options if: :"Accounts?" do |payment_request|
    payment_request.validates_presence_of :due_date, :purpose_of_payment # , :supplier_bank_details
  end
  validate :due_date_cannot_be_in_the_past

  def due_date_cannot_be_in_the_past
    if self.due_date.present? && self.due_date < Date.today
      errors.add(:due_date, 'cannot be less than Today')
    end
  end

  after_initialize :set_defaults, if: :new_record?
  def set_defaults
    self.status ||= :'Payment Pending'
    self.request_owner ||= :'Logistics'
  end

  def update_status!
    if self.status == 'Payment Pending' || self.status == 'Partial Payment Made' || self.status == 'Payment Made' || self.status == 'Partial Payment Pending'
      if self.transactions.present?
        if self.percent_amount_paid == 100.0
          self.status = :'Payment Made'
        else
          self.status = :'Partial Payment Made'
        end
      else
        self.status = :'Payment Pending'
      end
    end
  end

  def grouped_status
    grouped_status = {}
    status_category = { 10 => 'Pending', 30 => 'Rejected', 40 => 'Payment on Hold', 50 => 'Completed', 70 => 'Refund', 80 => 'Cancelled' }
    status_category.each do |index, category|
      grouped_status[category] = PaymentRequest.statuses.collect { |status, v|
      if v.between?(index, index + 9)
        status
      end}.compact
    end
    grouped_status
  end


  def total_amount_paid
    self.transactions.persisted.map(&:amount_paid).compact.sum
  end

  def remaining_amount
    if self.po_request.purchase_order.present?
      if self.po_request.purchase_order.try(:calculated_total_with_tax) >= self.total_amount_paid
        self.po_request.purchase_order.try(:calculated_total_with_tax) - self.total_amount_paid
      end
    else
      0.0
    end
  end

  def percent_amount_paid
    if self.po_request.purchase_order.present?
      self.total_amount_paid * 100 / self.po_request.purchase_order.try(:calculated_total_with_tax)
    else
      0.0
    end
  end
end
