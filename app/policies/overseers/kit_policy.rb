class Overseers::KitPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def new?
    admin?
  end

  def comments?
    record.persisted?
  end


  def customer_bp_catalog?
    index?
  end

  def best_prices_and_supplier_bp_catalog?
    index?
  end

  def sku_purchase_history?
    index? && record.inquiry_products.any?
  end

end