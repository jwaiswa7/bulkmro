class Overseers::PoRequestPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def edit
    developer? || logistics? || manager_or_sales? || admin?
  end

  def pending_and_rejected?
    index?
  end

  def cancelled?
    index?
  end

  def amended?
    index?
  end

  def new_purchase_order?
    true
  end

  def new?
    true
  end

  def can_cancel?
    record.purchase_order.present? && (manager_or_sales? || admin?) && record.not_amending?
  end

  def can_reject?
    record.purchase_order.blank? && (logistics? || admin?)
  end

  def can_update_rejected_po_requests?
    record.purchase_order.present? && (manager_or_sales? || admin? ) && record.status == "Rejected"
  end

  def can_process_amended_po_requests?
    record.purchase_order.present? && (logistics? || admin?) && record.amending?
  end

  def show_payment_request?
    record.payment_request.present?
  end

  def new_payment_request?
    record.purchase_order.present? && record.payment_request.blank? && record.not_amending?
  end

  def edit_payment_request?
    record.payment_request.present?
  end
end