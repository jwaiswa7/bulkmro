class Overseers::SalesReceiptPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics?
  end

  def show?
    manager_or_sales? || logistics?
  end
end