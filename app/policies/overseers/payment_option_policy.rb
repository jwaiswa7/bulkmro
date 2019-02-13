class Overseers::PaymentOptionPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end
