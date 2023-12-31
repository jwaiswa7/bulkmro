# frozen_string_literal: true

class Overseers::PoRequestPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def edit?
    logistics? || manager_or_sales?
  end

  def pending_and_rejected?
    index?
  end

  def cancelled?
    index?
  end

  def under_amend?
    index?
  end

  def amended?
    index?
  end

  def new_purchase_order?
    record.status == 'Supplier PO: Request Pending' || record.stock_status == 'Stock Requested' || record.status == 'Supplier PO: Amendment Pending'
  end

  def new?
    sales? || manager_or_sales?
  end

  def add_service_product?
    manager_or_sales?
  end

  def can_supplier_po_request_pending?
    record.purchase_order.blank? && (manager_or_sales? || admin?) && record.status == 'Supplier PO: Request Pending'
  end

  def can_supplier_po_created_not_sent_requests?
    record.purchase_order.blank? && (logistics? || admin?) && record.status == 'Supplier PO: Request Pending'
  end

  def can_amend_completed_po_requests?
    record.purchase_order.present? && (admin? || manager_or_sales?) && (record.status == 'Supplier PO: Created Not Sent' || record.status == 'Supplier PO: Amended')
  end

  def can_process_amended_po_requests?
    record.purchase_order.present? && (logistics? || admin?) && record.amending?
  end

  def can_cancel?
    record.status != 'Cancelled'
  end

  def can_reject?
    record.purchase_order.blank? && record.status == 'Supplier PO: Request Pending' && record.status != 'Supplier PO Request Rejected'
  end

  def can_update_rejected_po_requests?
    record.purchase_order.blank? && (manager_or_sales? || admin?) && record.status == 'Supplier PO Request Rejected'
  end

  def show_payment_request?
    record.payment_request.present?
  end

  def new_payment_request?
    record.purchase_order.present? && record.payment_request.blank? && record.not_amending? && record.not_cancelled?
  end

  def edit_payment_request?
    record.payment_request.present?
  end

  def sending_po_to_supplier_new_email_message?
    record.purchase_order && record.contact.present? && (record.status != 'Cancelled' || record.stock_status == 'Supplier PO Request Rejected' || record.status == 'Supplier PO Sent')
  end

  def sending_po_to_supplier_create_email_message?
    sending_po_to_supplier_new_email_message?
  end

  def dispatch_supplier_delayed_new_email_message?
    (record.status == 'Supplier PO: Created Not Sent' || record.status == 'Supplier PO Sent' || record.stock_status == 'Stock Supplier PO Created') && (admin? || logistics?) && record.purchase_order && record.contact.present?
  end

  def dispatch_supplier_delayed_create_email_message?
    dispatch_supplier_delayed_new_email_message?
  end

  def material_received_in_bm_warehouse_new_email_msg?
    (record.status == 'Supplier PO: Created Not Sent' || record.status == 'Supplier PO Sent' || record.stock_status == 'Stock Supplier PO Created') && (admin? || logistics?) && record.purchase_order && record.contact.present? && record.purchase_order.material_status.present?
  end

  def material_received_in_bm_warehouse_create_email_msg?
    material_received_in_bm_warehouse_new_email_msg?
  end

  def cancel_porequest?
    update?
  end

  def render_modal_form?
    add_comment? || can_cancel? || can_reject?
  end

  def add_comment?
    index?
  end

  def stock?
    index? && (sales? || admin? || logistics?)
  end

  def pending_stock_approval?
    index? && (manager_or_sales? || admin? || logistics?)
  end

  def completed_stock?
    index? && (logistics? || manager_or_sales? || admin?)
  end

  def can_reject_stock_po?
    record.purchase_order.blank? && (manager? || admin? || logistics?)
  end

  def new_purchase_order?
    logistics? || admin? || (overseer.acl_role_id == Settings.inside_sales_manager.role_id)
  end

  def reject_purchase_order_modal?
    logistics? || admin?
  end

  def rejected_purchase_order?
    reject_purchase_order_modal?
  end

  def create_purchase_order?
    reject_purchase_order_modal?
  end

  def can_edit_payment_option?
    record.status != "Supplier PO Sent" || ['Inside Sales Manager','Admin','Inside Sales and Logistic Manager','Admin-Leadership Team','Inside Sales Team Leader','Account Manager'].include?(overseer.acl_role.role_name)
  end

  class Scope
    attr_reader :overseer, :scope

    def initialize(overseer, scope)
      @overseer = overseer
      @scope = scope
    end

    def resolve
      if overseer.allow_inquiries?
        scope.all
      else
        scope.joins('INNER JOIN inquiries ON inquiries.id = po_requests.inquiry_id').where('inquiries.inside_sales_owner_id IN (:overseer) OR inquiries.outside_sales_owner_id IN (:overseer) OR inquiries.procurement_operations_id IN (:overseer) OR po_requests.created_by_id IN (:overseer)', overseer: overseer.self_and_descendants.pluck(:id))
      end
    end
  end
end
