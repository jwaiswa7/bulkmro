

class Overseers::CustomerProductPolicy < Overseers::ApplicationPolicy
  def generate_catalog?
    true
  end

  def destroy_all?
    developer?
  end

  def destroy?
    record.customer_order_rows.blank?
  end
end
