class Overseers::CategoryPolicy < Overseers::ApplicationPolicy
  def autocomplete_closure_tree?
    autocomplete?
  end

  def index?
    manager?
  end
end