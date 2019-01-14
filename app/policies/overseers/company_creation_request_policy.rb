class Overseers::CompanyCreationRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || cataloging?
  end

end