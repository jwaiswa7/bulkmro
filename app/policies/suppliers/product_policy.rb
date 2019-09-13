# frozen_string_literal: true

class Suppliers::ProductPolicy < Suppliers::ApplicationPolicy
  def index?
    true
  end
end
