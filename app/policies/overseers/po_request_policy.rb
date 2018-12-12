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
    record.has_purchase_order
  end
end