# frozen_string_literal: true

class Overseers::CustomerOrderPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_cataloging? || admin?
  end

  def show?
    manager_or_cataloging? || admin?
  end

  def convert?
    admin? && record.approved?
  end

  def company_customer_orders?
    manager_or_cataloging? || admin?
  end

  def can_create_inquiry?
    !record.inquiry.present? && record.approved?
  end

  def approve?
    record.not_approved? && !record.rejected?
  end

  def reject?
    approve?
  end
end
