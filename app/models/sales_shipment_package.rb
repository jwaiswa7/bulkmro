class SalesShipmentPackage < ApplicationRecord
  belongs_to :sales_shipment
  belongs_to :sales_invoice


end
