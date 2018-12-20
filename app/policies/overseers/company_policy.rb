class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any? && manager_or_sales? && record.is_active? && record.is_supplier?
  end

  def new_contact?
    edit? && record.is_active?
  end

  def new_address?
    edit? && record.is_active?
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
end