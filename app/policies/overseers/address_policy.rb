class Overseers::AddressPolicy < Overseers::ApplicationPolicy
  def new?
    super && !sales?
  end
end