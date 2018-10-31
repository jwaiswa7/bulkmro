class Overseers::SalesInvoicePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def show_original_invoice?
    record.original_invoice.attached?
  end

  def export_all?
    admin_or_manager?
  end
end