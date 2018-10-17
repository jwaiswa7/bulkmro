class Overseers::ApplicationPolicy
  attr_reader :overseer, :record

  def initialize(overseer, record)
    @overseer = overseer
    @record = record
  end

  def admin?
    overseer.adminstrator?
  end

  def manager?
    overseer.manager?
  end

  def person?
    overseer.person?
  end

  def index?
    person?
  end

  def autocomplete?
    true
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    new?
  end

  def edit?
    create?
  end

  def update?
    edit?
  end

  def destroy?
    manager?
  end

  def dev?
    Rails.env.development?
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
