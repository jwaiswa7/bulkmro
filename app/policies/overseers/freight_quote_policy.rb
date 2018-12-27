class Overseers::FreightQuotePolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def new?
    index?
  end

  def edit?
    logistics? || admin?
  end
end