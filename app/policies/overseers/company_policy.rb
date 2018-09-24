class Overseers::CompanyPolicy < Overseers::ApplicationPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any?
  end
end