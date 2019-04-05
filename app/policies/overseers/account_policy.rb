# frozen_string_literal: true

class Overseers::AccountPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging? || logistics?
  end

  def autocomplete_supplier?
    index?
  end
end
