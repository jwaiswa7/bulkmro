class MaterialPickupRequest < ApplicationRecord
  COMMENTS_CLASS = 'MprComment'

  include Mixins::HasComments
  include Mixins::CanBeStamped

  update_index('material_pickup_requests#material_pickup_request') {self}
  belongs_to :purchase_order
  has_one :inquiry, :through => :purchase_order

  belongs_to :logistics_owner, -> (record) {where(role: 'logistics')}, class_name: 'Overseer', foreign_key: 'logistics_owner_id', optional: true
  has_many :rows, -> {joins(:purchase_order_row)}, class_name: 'MprRow', inverse_of: :material_pickup_request, dependent: :destroy
  has_many_attached :attachments
  has_one :invoice_request
  accepts_nested_attributes_for :rows, reject_if: lambda {|attributes| attributes['purchase_order_row_id'].blank? && attributes['id'].blank?}, allow_destroy: true
  validates_associated :rows
  enum document_types: {
      'Tax Invoice': 10,
      'Proforma Invoice': 20
  }

  enum status: {
      'Material Pickup': 10,
      'Material Delivered': 20
  }

  enum dispatched_bies: {
      'Supplier': 10,
      'Bulk MRO': 20
  }

  enum shipped_tos: {
      'BM Warehouse': 10,
      'Customer Warehouse': 20
  }

  enum logistics_partners: {
      'Aramex': 10,
      'FedEx': 11,
      'Spoton': 12,
      'Safex': 13,
      'Professional': 14,
      'DTDC': 15,
      'Delhivery': 16,
      'UPS': 17,
      'Blue Dart': 18,
      'BM Runner': 20,
      'Drop Ship': 30
  }

  scope :with_includes, -> {includes(:inquiry).includes(:purchase_order)}
  scope :'3PL', -> {where(logistics_partner: [10,11,12,13,14,15,16,17,18])}
  after_initialize :set_defaults, if: :new_record?

  validates_length_of :rows, minimum: 1, message: "must have at least one product", :on => :update
  validates :attachments, presence: true, if: :material_delivered?
  validates :document_type, presence: true, if: :attachments?
  validate :date_validation

  def grouped_status
    grouped_status = {}
    status_category = {10 => '3PL', 20 => 'BM Runner', 30 => 'Drop Ship'}
    status_category.each do |index, category|
      grouped_status[category] = MaterialPickupRequest.logistics_partners.collect {|status, v| ;
      if v.between?(index, index + 9);
        status;
      end}.compact
    end
    grouped_status
  end

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
    self.expected_delivery_date = purchase_order.po_request.supplier_committed_date if purchase_order.po_request.present?
  end

  def readable_status
    [status, "Request"].join(" ")
  end

  def to_s
    [readable_status, "##{self.id}"].join(" ")
  end
end
