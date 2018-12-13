class Overseers::PaymentRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def new?
    index?
  end
end