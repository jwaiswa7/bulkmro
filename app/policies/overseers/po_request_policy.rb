class Overseers::PoRequestPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def edit
    developer? || logistics? || manager_or_sales?
  end


  def pending_and_rejected?
    index?
  end

  def cancelled?
    index?
  end

  def new_purchase_order?
    true
  end

  def new?
    true
  end

  def can_cancel?
    manager_or_sales?
  end

  def can_reject?
    logistics?
  end

  def show_payment_request?
    record.payment_request.present?
  end

  def new_payment_request?
    record.purchase_order.present? && record.payment_request.blank?
  end

  def edit_payment_request?
    record.payment_request.present?
  end

  def preview_stock_po_request?
    true
  end
end