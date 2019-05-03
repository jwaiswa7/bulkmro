# frozen_string_literal: true

class Overseers::BrandPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end
