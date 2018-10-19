class Overseers::CompanyPolicy < Overseers::AccountPolicy
  def new_inquiry?
    record.contacts.any? && record.addresses.any?
  end
end