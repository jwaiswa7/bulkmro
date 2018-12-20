class Overseers::ContactPolicy < Overseers::ApplicationPolicy
  def become?
    true
  end

  def new?
    cataloging? || admin?
  end

  def edit?
    record.company.is_active if record.company.present?
  end

end