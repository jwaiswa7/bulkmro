class Overseers::IfscCodePolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def suggestion?
    true
  end
end