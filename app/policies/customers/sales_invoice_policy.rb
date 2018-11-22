class Customers::SalesInvoicePolicy < Customers::ApplicationPolicy
  def show_original_invoice?
    Overseers::SalesInvoicePolicy.new(contact, record).show_original_invoice?
  end

  def show?
    Overseers::SalesInvoicePolicy.new(contact, record).show?
  end
end