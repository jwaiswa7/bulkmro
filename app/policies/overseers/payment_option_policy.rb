# frozen_string_literal: true

class Overseers::PaymentOptionPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end
