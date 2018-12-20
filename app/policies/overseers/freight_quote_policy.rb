class Overseers::FreightQuotePolicy < Overseers::ApplicationPolicy
  def index?
    logistics? || admin?
  end

  def new?
    index?
  end
end