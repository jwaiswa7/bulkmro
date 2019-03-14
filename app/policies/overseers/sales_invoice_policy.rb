# frozen_string_literal: true

class Overseers::SalesInvoicePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.original_invoice.attached?
  end

  def payment_collection?
    index?
  end

  def ageing_report?
    index?
  end

  def edit_mis_date?
    record.persisted? && ['vijay.manjrekar@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com'].include?(overseer.email)
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
    record.persisted? && record.not_legacy?
  end

  def update_pod?
    edit_pod?
  end

  def search_or_create?
    manager_or_sales? || logistics?
  end

  def show_pending_ap_invoice_queue?
    index? && (admin? || accounts?)
  end
end
