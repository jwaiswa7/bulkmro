class Overseers::ReviewQuestionPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || developer?
  end

  def delete?
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