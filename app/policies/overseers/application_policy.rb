class Overseers::ApplicationPolicy
  attr_reader :overseer, :record

  def initialize(overseer, record)
    @overseer = overseer
    @record = record
  end

  def admin?
    overseer.administrator?
  end

  def manager?
    overseer.manager?
  end

  def admin_or_manager?
    admin? || manager?
  end

  def person?
    overseer.person?
  end

  def executive?
    overseer.executive?
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
      if  overseer.manager?
        scope.all
      else
        scope.where(:created_by => overseer.self_and_descendants)
      end
    end
  end
end
