class Overseers::AddressPolicy < Overseers::ApplicationPolicy
  def edit_remote_uid?
    admin?
  end
end