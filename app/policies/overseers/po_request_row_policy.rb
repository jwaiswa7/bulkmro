# frozen_string_literal: true

class Overseers::PoRequestRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    true
  end
end
