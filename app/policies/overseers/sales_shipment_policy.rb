# frozen_string_literal: true

class Overseers::SalesShipmentPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.shipment_pdf.attached?
  end

  def show_shipment_pdf?
    record.shipment_pdf.attached?
  end

  def relationship_map?
    all_roles?
  end

  def get_relationship_map_json?
    relationship_map?
  end
end
