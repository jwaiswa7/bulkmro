class Overseers::ReviewQuestionPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || developer?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  def edit?
    index?
  end

  def new?
    index?
  end
end