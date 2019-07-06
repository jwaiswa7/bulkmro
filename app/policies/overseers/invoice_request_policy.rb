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

  def can_cancel_or_reject?
    admin? || accounts?
  end

  def edit?
    admin? || accounts? || logistics?
  end

  def cancelled?
    admin? || accounts?
  end

  def render_cancellation_form?
    can_cancel_or_reject? || add_comment?
  end

  def cancel_invoice_request?
    update?
  end

  def render_modal_form?
    index?
  end

  def add_comment?
    index?
  end
end
