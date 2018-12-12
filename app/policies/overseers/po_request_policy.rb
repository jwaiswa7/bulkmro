class Overseers::PoRequestPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def pending?
    index?
  end

  def new_purchase_order?
    true
  end

  def new?
    true
  end

  def can_request_payment?
    has_purchase_order? && !has_payment_request?
  end

  def has_purchase_order?
    record.purchase_order.present?
  end

  def has_payment_request?
    record.payment_request.present?
  end

end