

class Overseers::MeasurementUnitPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end
