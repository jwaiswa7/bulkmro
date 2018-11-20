class Overseers::PurchaseOrderQueuePolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def new_purchase_order?
    true
  end

  def new?
    true
  end

end