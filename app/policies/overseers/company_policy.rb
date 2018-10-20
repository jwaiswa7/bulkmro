class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any? && !cataloging?
  end

  def new?
    all_roles? && !sales?
  end
end