class Overseers::BrandPolicy < Overseers::ManagerApplicationPolicy
  def brand_suppliers?
    index?
  end
end