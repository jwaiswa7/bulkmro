class Overseers::PaymentRequestPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def edit_payment_queue?
    accounts?
  end

  def edit_payment_logistics?
    manager_or_sales? || logistics? || admin?
  end
end