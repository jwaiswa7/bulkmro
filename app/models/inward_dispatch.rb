class InwardDispatch < ApplicationRecord
  COMMENTS_CLASS = 'InwardDispatchComment'

  include Mixins::HasComments
  include Mixins::CanBeStamped
  include Mixins::GetOverallDate

  update_index('inward_dispatches#inward_dispatch') { self }
  belongs_to :purchase_order
  has_one :inquiry, through: :purchase_order

  belongs_to :logistics_owner, -> (record) { where(role: 'logistics') }, class_name: 'Overseer', foreign_key: 'logistics_owner_id', optional: true
  has_many :rows, -> { joins(:purchase_order_row) }, class_name: 'InwardDispatchRow', inverse_of: :inward_dispatch, dependent: :destroy
  has_many_attached :attachments
  belongs_to :invoice_request, optional: true
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['purchase_order_row_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  validates_associated :rows
  enum document_types: {
      'Tax Invoice': 10,
      'Proforma Invoice': 20,
      'Delivery Challan': 30
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
      'Aramex': 1,
      'FedEx': 2,
      'Spoton': 3,
      'Safe Xpress': 4,
      'Professional Couriers': 5,
      'DTDC': 5,
      'Delhivery': 7,
      'UPS': 8,
      'Blue Dart': 9,
      'Anjani Courier': 10,
      'Mahavir Courier Services': 11,
      'Elite Enterprise': 12,
      'Sri Krishna Logistics': 13,
      'Maruti Courier': 14,
      'Vinod': 20,
      'Ganesh': 21,
      'Tushar': 22,
      'Others': 40,
      'Drop Ship': 60
  }

  enum logistics_aggregator: {
      'PS Enterprises': 10,
      'Elite Enterprise': 20
  }, _prefix: true

  scope :with_includes, -> { includes(:inquiry).includes(:purchase_order) }
  scope :'3PL', -> { where(logistics_partner: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]) }
  scope :'BM Runner', -> { where(logistics_partner: [20, 21, 22]) }
  after_initialize :set_defaults, if: :new_record?

  validates_length_of :rows, minimum: 1, message: 'must have at least one product', on: :update
  validates :attachments, presence: true, if: :material_delivered?
  validates :document_type, presence: true, if: :attachments?
  validate :date_validation

  def grouped_status
    grouped_status = {}
    status_category = { 1 => '3PL', 20 => 'BM Runner', 40 => 'Others', 60 => 'Drop Ship' }
    status_category.each do |index, category|
      grouped_status[category] = InwardDispatch.logistics_partners.collect { |status, v|
      if v.between?(index, index + 13)
        status
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

  def show_supplier_delivery_date
    get_overall_date(self)
  end

  # @return [Boolean]
  def attachments?
    attachments.any? || material_delivered?
  end

  def date_validation
    errors[:expected_delivery_date] << ' Cannot be less than Expected Dispatch Date' if self[:expected_delivery_date] < self[:expected_dispatch_date]
  end

  def set_defaults
    self.expected_delivery_date = purchase_order.po_request.supplier_committed_date if purchase_order.po_request.present?
  end

  def readable_status
    [status, 'Request'].join(' ')
  end

  def to_s
    [readable_status, "##{self.id}"].join(' ')
  end
end
