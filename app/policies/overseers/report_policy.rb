class Overseers::ReportPolicy < Overseers::ApplicationPolicy

  def index?
    super && !cataloging?
  end

end