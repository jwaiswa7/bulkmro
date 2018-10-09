class SalesShipment < ApplicationRecord
  include Mixins::CanBeSynced
  include Mixins::CanBeStamped

  belongs_to :sales_order
  has_many :rows, :class_name => 'SalesShipmentRow', inverse_of: :sales_shipment
  has_many :packages, :class_name => 'SalesShipmentPackage', inverse_of: :sales_shipment

  enum status: {
      default: 10,
      cancelled: 20
  }, _prefix: true

  validates_presence_of :status

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.status ||= :default
  end
end
