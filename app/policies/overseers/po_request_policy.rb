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

  def amended?
    index?
  end

  def new_purchase_order?
    true
  end

  def new?
    sales? || manager_or_sales?
  end

  def add_service_product?
    manager_or_sales?
  end

  def can_cancel?
    record.purchase_order.present? && (manager_or_sales?) && record.not_amending?
  end

  def can_reject?
    record.purchase_order.blank? && (logistics? || admin?)
  end

  def can_update_rejected_po_requests?
    record.purchase_order.present? && (manager_or_sales?) && record.status == 'Rejected'
  end

  def can_process_amended_po_requests?
    record.purchase_order.present? && (logistics? || admin? || manager_or_sales?) && record.amending?
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
    record.status == 'Supplier PO Created Not Sent' && record.purchase_order && record.contact.present?
  end

  def sending_po_to_supplier_create_email_message?
    sending_po_to_supplier_new_email_message?
  end

  def dispatch_supplier_delayed_new_email_message?
    record.status == 'Supplier PO Created Not Sent' && (admin? || logistics?) && record.purchase_order && record.contact.present?
  end

  def dispatch_supplier_delayed_create_email_message?
    dispatch_supplier_delayed_new_email_message?
  end

  def material_received_in_bm_warehouse_new_email_msg?
    record.status == 'Supplier PO Created Not Sent' && (admin? || logistics?) && record.purchase_order && record.contact.present? && record.purchase_order.material_status.present?
  end

  def material_received_in_bm_warehouse_create_email_msg?
    material_received_in_bm_warehouse_new_email_msg?
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
        scope.joins('INNER JOIN inquiries ON inquiries.id = po_requests.inquiry_id').where('inquiries.inside_sales_owner_id IN (:overseer) OR inquiries.outside_sales_owner_id IN (:overseer) OR po_requests.created_by_id IN (:overseer)', overseer: overseer.self_and_descendants.pluck(:id))
      end
    end
  end
end
