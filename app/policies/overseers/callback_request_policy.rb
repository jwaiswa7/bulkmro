# frozen_string_literal: true

class Overseers::CallbackRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end
end
