class Overseers::AddressPolicy < Overseers::ApplicationPolicy
  def edit_remote_uid?
    developer? && record.persisted?
  end
end