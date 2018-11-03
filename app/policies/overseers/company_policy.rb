class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any? && manager_or_sales?
  end

  def new?
    manager_or_cataloging?
  end

  def export_all?
    admin_or_manager?
  end
end