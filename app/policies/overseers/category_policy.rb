class Overseers::CategoryPolicy < Overseers::ApplicationPolicy
  def autocomplete_closure_tree?
    autocomplete?
  end

  def index?
    sales_manager?
  end
end