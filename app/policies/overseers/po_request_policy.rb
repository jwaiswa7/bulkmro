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

  def show_payment_request?
    record.payment_request.present?
  end

  def new_payment_request?
    record.purchase_order.present? && record.payment_request.blank?
  end

  def edit_payment_request?
    record.payment_request.present?
  end

  def new_email_message?
    (manager_or_sales? || logistics?) && record.status == "PO Created" && record.purchase_order.has_supplier? && record.purchase_order.get_supplier(record.purchase_order.rows.first.metadata['PopProductId'].to_i).company_contacts.present?
  end

  def create_email_message?
    new_email_message?
  end
end