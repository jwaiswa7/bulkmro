class Overseers::CompanyCreationRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || cataloging?
  end

  def requested?
    index?
  end

  def created?
    index?
  end

end