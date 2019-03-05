# frozen_string_literal: true

class Overseers::PurchaseOrderPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.document.attached?
  end

  def edit?
    logistics? || admin?
  end

  def autocomplete?
    manager_or_sales? || logistics?
  end

  def autocomplete_without_po_requests?
    manager_or_sales? || logistics?
  end

  def export_all?
    allow_export? || allow_logistics_format_export?
  end

  def show_document?
    record.document.attached?
  end

  def can_request_invoice?
    !record.invoice_request.present?
  end

  def edit_material_followup?
    edit?
  end

  def update_material_followup?
    edit?
  end

  def material_readiness_queue?
    edit?
  end

  def new_pickup_request?
    (record.rows.sum(&:get_pickup_quantity) > 0) && record.followup_date.present?
  end

  def material_pickup_queue?
    edit?
  end

  def material_delivered_queue?
    edit?
  end

  def new_email_message?
    (manager_or_sales? || logistics?) && record.po_request.present? && record.has_supplier? && record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).company_contacts.present?
  end

  def create_email_message?
    new_email_message?
  end

  def update_logistics_owner?
    admin? || logistics?
  end

  def update_logistics_owner_for_pickup_requests?
    admin? || logistics?
  end
end
