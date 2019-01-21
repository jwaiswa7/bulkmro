class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments
  include Mixins::HasConvertedCalculations

  pg_search_scope :locate, :against => [:id], :associated_against => {:sales_order => [:id, :order_number], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :sales_order
  belongs_to :inquiry
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :logistics_owner, -> (record) {where(:role => 'logistics')}, :class_name => 'Overseer', foreign_key: 'logistics_owner_id', required: false
  has_many :rows, class_name: 'PoRequestRow', :inverse_of => :po_request, dependent: :destroy
  accepts_nested_attributes_for :rows, allow_destroy: true
  belongs_to :address, required: false
  belongs_to :contact, required: false

  belongs_to :purchase_order, required: false
  has_one :payment_request, required: false
  has_one :payment_option, :through => :purchase_order
  has_many_attached :attachments

  attr_accessor :opportunity_type, :customer_committed_date

  enum status: {
      :'Requested' => 10,
      :'PO Created' => 20,
      :'Cancelled' => 30,
      :'Rejected' => 40
  }

  # enum supplier_po_type: {
  #     :amazon => 10,
  #     :rate_contract => 20,
  #     :financing => 30,
  #     :regular => 40,
  #     :service => 50,
  #     :repeat => 60,
  #     :list => 65,
  #     :route_through => 70,
  #     :tender => 80
  # }

  enum rejection_reason: {
    :'Not Found: Supplier in SAP' => 10,
    :'Not Found: Supplier GST Number' => 20,
    :'Not Found: Supplier Address' => 30,
    :'Mismatch: HSN / SAC Code' => 40,
    :'Mismatch: Tax Rates' => 50,
    :'Mismatch: Supplier Billing or Shipping Address' => 60,
    :'Mismatch: Supplier GST Number' => 70,
    :'Others' => 80
  }

  scope :pending_and_rejected, -> {where(:status => [:'Requested', :'Rejected'])}
  scope :handled, -> {where.not(:status => [:'Requested'])}
  scope :not_cancelled, -> {where.not(:status => [:'Cancelled'])}
  scope :cancelled, -> {where(:status => [:'Cancelled'])}

  validate :purchase_order_created?
  validates_uniqueness_of :purchase_order, if: -> { purchase_order.present? }
  validate :update_reason_for_status_change?

  after_initialize :set_defaults, :if => :new_record?

  def purchase_order_created?
    if self.status == "PO Created" && self.purchase_order.blank?
      errors.add(:purchase_order, ' number is mandatory')
    end
  end

  def update_reason_for_status_change?
    if (self.status == 'Cancelled' && self.cancellation_reason.blank?) || (self.status == 'Rejected' && self.rejection_reason.blank?)
      errors.add(:base, "Provide a reason to change the status to #{self.status} in message section")
    end
  end

  def set_defaults
    self.status ||= :'Requested'
  end

  def selling_price
   rows.sum(&:converted_total_selling_price).round(2)
  end

  def buying_price
    rows.sum(&:converted_total_buying_price).round(2)
  end

  def po_margin_percentage
    (((self.buying_price - self.selling_price) / self.buying_price) * 100).round(2) if self.buying_price > 0
  end

end