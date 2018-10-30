class Overseers::ContactPolicy < Overseers::ManagerApplicationPolicy

  def login_as_contact?
    true
  end
end