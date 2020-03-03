# frozen_string_literal: true

class Suppliers::ProductPolicy < Suppliers::ApplicationPolicy
  def index?
    true
  end

  def update_price?
    true
  end
end
