class Overseers::ContactPolicy < Overseers::ApplicationPolicy
  def login_as_contact?
    true
  end
end