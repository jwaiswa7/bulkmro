class Overseers::CustomerFeedback < Overseers::ApplicationPolicy
  def index?
    admin?
  end
end
  