class SalesShipment < ApplicationRecord
  include Mixins::CanBeSynced
  include Mixins::CanBeStamped

  belongs_to :sales_order
  has_many :rows, :class_name => 'SalesShipmentRow', inverse_of: :sales_shipment
end
