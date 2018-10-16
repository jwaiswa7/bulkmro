class Overseers::SalesShipmentPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && !record.shipment_pdf.attached?
  end

  def show_shipment_pdf?
    record.shipment_pdf.attached?
  end
end