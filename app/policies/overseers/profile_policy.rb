# frozen_string_literal: true

class Overseers::ProfilePolicy < Overseers::ApplicationPolicy
  def edit?
    true
  end

  def update?
    edit?
  end
end
