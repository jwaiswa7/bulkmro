class Overseers::ProductPolicy < Overseers::ApplicationPolicy

  def comments?
    record.persisted?
  end

  def pending?
    index? && manager?
  end

  def approve?
    pending? && record.not_approved? && !record.rejected?
  end

  def reject?
    approve?
  end

  def merge?
    approve?
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

  def resync?
    record.approved? && record.not_synced?
  end
end