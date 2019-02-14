

class Overseers::WarehousePolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end

  def show_product_stocks?
    manager_or_cataloging?
  end
end
