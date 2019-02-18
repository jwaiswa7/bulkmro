# frozen_string_literal: true

class Overseers::WarehousePolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end
