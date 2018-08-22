class Overseers::ApplicationPolicy
  attr_reader :overseer, :record

  def initialize(overseer, record)
    @overseer = overseer
    @record = record
  end

  def admin?
    overseer.admin?
  end

  def sales?
    overseer.sales?
  end

  def index?
    admin? || sales?
  end

  def autocomplete?
    index?
  end

  def show?
    index?
  end

  def new?
    admin? || sales?
  end

  def create?
    new?
  end

  def edit?
    admin? || sales?
  end

  def update?
    edit?
  end

  def destroy?
    admin? || sales?
  end

  def scope
    Pundit.policy_scope!(overseer, record.class)
  end

  class Scope
    attr_reader :overseer, :scope

    def initialize(overseer, scope)
      @overseer = overseer
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
