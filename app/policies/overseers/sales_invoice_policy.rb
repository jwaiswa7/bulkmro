class Overseers::SalesInvoicePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def edit_mis_date?
    record.persisted? && ['vijay.manjrekar@bulkmro.com','gaurang.shah@bulkmro.com','devang.shah@bulkmro.com'].include?(overseer.email)
  end

  def update_mis_date?
    edit_mis_date?
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

  def edit_pod?
    record.persisted? && record.not_legacy?
  end

  def update_pod?
    edit_pod?
  end
end