# frozen_string_literal: true

class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any? && manager_or_sales? && record.is_active?
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

  def download_customer_product_template?
    all_roles?
  end

  def new_excel_customer_product_import?
    cataloging? || developer?
  end

  def create_customer_products?
    all_roles?
  end
end
