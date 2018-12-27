class Overseers::FreightQuotePolicy < Overseers::ApplicationPolicy
  def index?
    logistics? || admin?
  end

  def new?
    index?
  end

  def edit?
    index?
  end

  def show?
    manager_or_sales?
  end
end