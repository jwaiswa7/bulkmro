class Overseers::PaymentRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def requests_created?
    index?
  end

  def new?
    index?
  end

  def completed?
    index?
  end
end