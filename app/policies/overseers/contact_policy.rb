class Overseers::ContactPolicy < Overseers::ApplicationPolicy
  def become?
    true
  end
end