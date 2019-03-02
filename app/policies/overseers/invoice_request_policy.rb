# frozen_string_literal: true

class Overseers::InvoiceRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def pending?
    index?
  end

  def new?
    index?
  end

  def completed?
    index?
  end

  def edit?
    admin? || accounts?
  end

  def cancelled?
    admin? || accounts?
  end
end
