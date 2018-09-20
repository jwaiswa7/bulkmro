class Overseers::CategoryPolicy < Overseers::ApplicationPolicy
  def index?
    sales_manager?
  end
end