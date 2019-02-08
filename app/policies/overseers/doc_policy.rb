# frozen_string_literal: true

class Overseers::DocPolicy < Overseers::ApplicationPolicy
  def index
    admin?
  end
end
