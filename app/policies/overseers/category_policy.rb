# frozen_string_literal: true

class Overseers::CategoryPolicy < Overseers::ApplicationPolicy
  def autocomplete_closure_tree?
    autocomplete?
  end

  def new?
    manager_or_cataloging?
  end
end
