class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any? && manager_or_sales? && record.is_active?
  end

  def new?
    manager_or_cataloging? || logistics?
  end

  def export_all?
    allow_export?
  end
end