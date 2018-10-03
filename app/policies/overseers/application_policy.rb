class Overseers::ApplicationPolicy
  attr_reader :overseer, :record

  def initialize(overseer, record)
    @overseer = overseer
    @record = record
  end

  def admin?
    overseer.admin?
  end

  def sales_manager?
    overseer.outside_sales_manager? || overseer.sales_manager? || admin?
  end

  def sales?
    overseer.inside_sales? || overseer.outside_sales? || overseer.sales? || sales_manager?
  end

  def index?
    admin? || sales?
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
    sales_manager?
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
