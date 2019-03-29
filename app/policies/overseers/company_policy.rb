# frozen_string_literal: true

class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any? && manager_or_sales? && is_active? && record.is_customer?
  end

  def new_contact?
    edit? && is_active?
  end

  def new_address?
    edit? && is_active?
  end

  def new?
    manager_or_cataloging? || logistics?
  end

  def edit_remote_uid?
    developer? && record.persisted?
  end

  def export_all?
    allow_export?
  end

  def export_filtered_records?
    allow_export? && overseer.can_send_emails?
  end

  def download_customer_product_template?
    all_roles? && is_active?
  end

  def new_excel_customer_product_import?
    cataloging? || developer? && is_active?
  end

  def payment_collection?
    index?
  end

  def ageing_report?
    index?
  end

  def create_customer_products?
    all_roles? && is_active?
  end

  def render_rating_form?
    index?
  end

  def update_rating?
    index?
  end

  def new_rating?
    record.is_supplier? && (manager? || sales? || logistics?)
  end
end
