class Overseers::BrandPolicy < Overseers::ManagerApplicationPolicy
  def brand_suppliers?
    index?
  end
  def supplier_summary?
    true
  end
end