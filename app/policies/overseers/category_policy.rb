class Overseers::CategoryPolicy < Overseers::ManagerApplicationPolicy
  def autocomplete_closure_tree?
    autocomplete?
  end

end