class Overseers::ArInvoicePolicy < Overseers::ApplicationPolicy
  def index?
    accounts? || admin?
  end
  def edit?
    accounts? || admin?
  end
end
