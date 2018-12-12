class Overseers::CustomerOrderPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_cataloging? || admin?
  end

  def show?
    manager_or_cataloging? || admin?
  end

  def convert?
    admin?
  end

  def company_customer_orders?
    manager_or_cataloging? || admin?
  end

  def can_create_inquiry?
    !record.inquiry.present?
  end
end