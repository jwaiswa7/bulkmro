class MaterialPickupRequest < ApplicationRecord
  COMMENTS_CLASS = 'MprComment'

  include Mixins::HasComments
  include Mixins::CanBeStamped

  belongs_to :purchase_order
  belongs_to :logistics_owner, -> (record) {where(role: 'logistics')}, class_name: 'Overseer', foreign_key: 'logistics_owner_id', optional: true
  has_many :rows, -> {joins(:purchase_order_row)}, class_name: 'MprRow', inverse_of: :material_pickup_request, dependent: :destroy
  has_many_attached :attachments
  accepts_nested_attributes_for :rows, reject_if: lambda {|attributes| attributes['purchase_order_row_id'].blank? && attributes['id'].blank?}, allow_destroy: true
  validates_associated :rows
  enum document_types: {
      'Tax Invoice': 10,
      'Proforma Invoice': 20
  }

  enum status: {
      'Material Pickup': 10,
      'Material Delivered': 20
  }, _prefix: true


  after_initialize :set_defaults, if: :new_record?

  validates_length_of :rows, minimum: 1, message: "must have at least one product", :on => :update
  validates :attachments, presence: true, if: :material_delivered?
  validates :document_type, presence: true, if: :attachments?
  validate :date_validation

  def material_delivered?
    status == 'Material Delivered'
  end

  def po_row_size
    purchase_order.rows.size
  end

  # @return [Boolean]
  def attachments?
    attachments.any? || material_delivered?
  end

  def date_validation
    errors[:expected_delivery_date] << " Cannot be less than Expected Dispatch Date" if self[:expected_delivery_date] < self[:expected_dispatch_date]
    errors[:actual_delivery_date] << " Cannot be less than Expected Dispatch Date" if self[:actual_delivery_date] < self[:expected_delivery_date]
  end

  def set_defaults
    self.expected_dispatch_date = DateTime.now
    self.expected_delivery_date = DateTime.now
    self.actual_delivery_date = DateTime.now
  end

  def readable_status
    [status, "Request"].join(" ")
  end

  def to_s
    [readable_status, "##{self.id}"].join(" ")
  end
end
