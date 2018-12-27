class Overseers::PaymentRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin? || others?
  end

  def edit_payment_queue?
    others?
  end
end