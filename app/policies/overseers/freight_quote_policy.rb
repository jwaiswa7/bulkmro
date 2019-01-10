class Overseers::FreightQuotePolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def new?
    logistics? || admin?
  end

  def edit?
    logistics? || admin?
  end

  def show?
    index?
  end
end