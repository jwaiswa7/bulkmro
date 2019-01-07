class Overseers::AddressPolicy < Overseers::ApplicationPolicy
  def edit_remote_uid?
    developer? && record.persisted?
  end

  def new?
    cataloging? || admin?
  end

  def edit?
    new?
  end

  def warehouse_addresses?
    true
  end

end