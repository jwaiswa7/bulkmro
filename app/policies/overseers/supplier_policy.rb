class Overseers::SupplierPolicy < Overseers::CompanyPolicy
  def export_all?
    allow_export?
  end
end
