class Overseers::PurchaseOrderQueuePolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def new_purchase_order?
    admin?
  end

  def new?
    admin?
  end

end