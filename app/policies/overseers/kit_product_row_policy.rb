# frozen_string_literal: true

class Overseers::KitProductRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    admin?
  end
end
