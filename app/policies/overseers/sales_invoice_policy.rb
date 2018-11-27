class Overseers::SalesInvoicePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def show_original_invoice?
    record.original_invoice.attached?
  end

  def export_all?
    allow_export?
  end

  def export_rows?
    allow_export?
  end

  def export_for_logistics?
    allow_logistics_format_export?
  end

  def add_pod?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def update_pod?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end
end