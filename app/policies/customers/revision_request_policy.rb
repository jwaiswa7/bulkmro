# frozen_string_literal: true

class Customers::RevisionRequestPolicy < Customers::ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end
end
  