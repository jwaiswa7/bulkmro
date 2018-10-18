class Overseers::CategoryPolicy < Overseers::ManagerPolicy
  def autocomplete_closure_tree?
    autocomplete?
  end

end