class Overseers::BrandPolicy < Overseers::ApplicationPolicy
  def new?
    super && !sales?
  end
end