class Overseers::PurchaseOrderPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.document.attached?
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
end