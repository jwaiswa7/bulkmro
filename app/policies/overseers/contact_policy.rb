class Overseers::ContactPolicy < Overseers::ApplicationPolicy
  def become?
    cataloging? || admin? || manager? || allow_customer_portal?
  end

  def new?
    cataloging? || admin?
  end

  def edit?
    record.company.is_active if record.company.present?
  end

end