class Overseers::PurchaseOrderPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.document.attached?
  end

  def edit?
    logistics? || admin?
  end

  def autocomplete?
    manager_or_sales? || logistics?
  end

  def export_all?
    allow_export? || allow_logistics_format_export?
  end

  def show_document?
    record.document.attached?
  end

  def can_request_invoice?
    !record.invoice_request.present?
  end

  def edit_material_status?
    edit?
  end

  def update_material_status?
    edit?
  end

  def material_readiness_queue?
    edit?
  end

  def new_pickup_request?
    record.rows.sum(&:get_pickup_quantity) > 0
  end

  def material_pickup_queue?
    edit?
  end

  def material_delivered_queue?
    edit?
  end
end