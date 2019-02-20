class SalesShipmentPackage < ApplicationRecord
  belongs_to :sales_shipment
  has_one :sales_order, through: :sales_shipment
  # belongs_to :sales_order
  # belongs_to :sales_invoice
end
