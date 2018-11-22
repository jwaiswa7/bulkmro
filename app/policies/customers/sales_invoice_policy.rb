class Customers::SalesInvoicePolicy < Customers::ApplicationPolicy
  def show_original_invoice?
    Overseers::SalesInvoicePolicy.new(overseer, record).show_original_invoice?
  end

  def show?
    Overseers::SalesInvoicePolicy.new(overseer, record).show?
  end
end