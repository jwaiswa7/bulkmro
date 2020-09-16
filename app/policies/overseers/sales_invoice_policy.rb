# frozen_string_literal: true

class Overseers::SalesInvoicePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def edit_mis_date?
    record.persisted? && ['vijay.manjrekar@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com', 'bhargav.trivedi@bulkmro.com'].include?(overseer.email)
  end

  def update_mis_date?
    edit_mis_date?
  end

  def show_original_invoice?
    record.original_invoice.attached?
  end

  def make_zip?
    show?
  end

  def export_all?
    allow_export?
  end

  def export_rows?
    allow_export?
  end

  def export_for_logistics?
    allow_logistics_format_export?
  end

  def edit_pod?
    record.persisted? && record.status != 'Cancelled'
  end

  def view_pod?
    record.persisted? && record.status != 'Cancelled' && inside?
  end

  def update_pod?
    edit_pod?
  end

  def search_or_create?
    manager_or_sales? || logistics?
  end
  def relationship_map?
    all_roles?
  end

  def get_relationship_map_json?
    relationship_map?
  end

  def show_pending_ap_invoice_queue?
    index? && (admin? || accounts? || manager_or_sales?)
  end

  def new_email_message?
    record.persisted? && overseer.can_send_emails?
  end

  def create_email_message?
    new_email_message?
  end

  def payment_collection?
    index?
  end

  def ageing_report?
    index?
  end

  def delivery_date_revision_allowed?
    record.pod_status != 'complete'
  end

  def can_create_outward_dispatch?
    (admin? || logistics?) && record.status != 'Cancelled' && (['partial','incomplete'].include? record.pod_status) && (!record.outward_dispatches.present? || (record.outward_dispatches.present? && (record.total_quantity_delivered > record.outward_dispatched_quantity)))
  end
end
