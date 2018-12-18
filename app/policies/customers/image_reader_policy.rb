class Customers::ImageReaderPolicy < Customers::ApplicationPolicy
  def export_all?
    true
  end

  def export_by_date?
    true
  end
end