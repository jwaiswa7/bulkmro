class Overseers::InvoiceRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def pending?
    index?
  end

  def new?
    index?
  end

  def completed?
    index?
  end
end
