class Overseers::MeasurementUnitPolicy < Overseers::ApplicationPolicy
  def new?
    super && !sales?
  end
end