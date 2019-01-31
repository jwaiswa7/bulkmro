class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id], :associated_against => {:sales_order => [:id, :order_number], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :sales_order
  belongs_to :inquiry
  belongs_to :logistics_owner, -> (record) {where(:role => 'logistics')}, :class_name => 'Overseer', foreign_key: 'logistics_owner_id'
  has_many :rows, class_name: 'PoRequestRow'
  accepts_nested_attributes_for :rows, allow_destroy: true

  belongs_to :purchase_order, required: false
  has_one :payment_request, required: false
  has_one :payment_option, :through => :purchase_order
  has_many_attached :attachments

  enum status: {
      :'Requested' => 10,
      :'PO Created' => 20,
      :'Cancelled' => 30
  }

  scope :pending, -> {where(:status => :'Requested')}
  scope :handled, -> {where.not(:status => :'Requested')}

  validate :purchase_order_created?
  validates_uniqueness_of :purchase_order, if: -> { purchase_order.present? }

  def purchase_order_created?
    if self.status == "PO Created" && self.purchase_order.blank?
      errors.add(:purchase_order, ' number is mandatory')
    end
  end

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status ||= :'Requested'
  end

  def sending_purchase_order(email_message, po_request, inquiry)
    subject = "Internal Ref Inq # #{inquiry.id} Purchase Order # #{po_request.purchase_order.po_number}"
    body = PoRequestMailer.purchase_order_details(email_message)
    return { subject: subject, body: body, auto_attach: true}
  end

  def dispatch_from_supplier_delayed(email_message, inquiry)
    subject = "Ref # #{inquiry.id} Delay in Material Delivery"
    body = PoRequestMailer.dispatch_supplier_delayed(email_message)
    return { subject: subject, body: body, auto_attach: false}
  end
end
