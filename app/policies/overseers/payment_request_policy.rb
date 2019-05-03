# frozen_string_literal: true

class Overseers::PaymentRequestPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def edit_payment_queue?
    accounts? || logistics? || admin?
  end

  def edit_payment_logistics?
    manager_or_sales? || logistics? || admin?
  end

  def payment_request_logistics_and_accounts?
    edit_payment_queue? || logistics?
  end

  def update_payment_status?
    accounts? || admin?
  end

  def show?
    accounts? || logistics? || sales? || admin?
  end

  def edit?
    accounts? || logistics? || admin?
  end
end
