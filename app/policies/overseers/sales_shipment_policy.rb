class Overseers::SalesShipmentPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.shipment_pdf.attached?
  end

  def show_shipment_pdf?
    record.shipment_pdf.attached?
  end
end
