class Overseers::CategoryPolicy < Overseers::ApplicationPolicy
  def autocomplete_closure_tree?
    autocomplete?
  end

  def new?
    super && !sales?
  end
end