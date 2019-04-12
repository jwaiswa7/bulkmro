# frozen_string_literal: true

class Overseers::InvoiceRequestPolicy < Overseers::ApplicationPolicy
  def index?
    accounts? || manager_or_sales? || logistics? || admin?
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

  def render_cancellation_form?
    admin? || accounts?
  end

  def cancel_invoice_request?
    update?
  end
end
