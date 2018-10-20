class Overseers::TaxCodePolicy < Overseers::ApplicationPolicy
  def new?
    super && !sales?
  end
end