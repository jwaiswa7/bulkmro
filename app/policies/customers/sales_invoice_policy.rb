class Customers::SalesInvoicePolicy < Customers::ApplicationPolicy
  def show_original_invoice?
    record.original_invoice.attached?
  end

  def show?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def edit_pod?
    record.persisted? && record.not_legacy?
  end

  def export_all?
    true
  end

  def show_pods?
    true
  end
end
