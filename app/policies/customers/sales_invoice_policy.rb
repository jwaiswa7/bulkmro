class Customers::SalesInvoicePolicy < Customers::ApplicationPolicy
  def show_original_invoice?
    record.original_invoice.attached?
  end
end