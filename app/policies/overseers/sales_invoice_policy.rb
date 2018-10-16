class Overseers::SalesInvoicePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && !record.original_invoice.attached?
  end

  def show_original_invoice?
    record.original_invoice.attached?
  end
end