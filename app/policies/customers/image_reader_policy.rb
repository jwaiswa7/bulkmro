

class Customers::ImageReaderPolicy < Customers::ApplicationPolicy
  def export_all?
    true
  end

  def index?
    contact.account_id == 2089
  end

  def export_by_date?
    true
  end
end
