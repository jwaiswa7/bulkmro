class Overseers::ArInvoiceRequestPolicy < Overseers::ApplicationPolicy
  def index?
    accounts? || admin?
  end

  def new?
    index?
  end

  def edit?
    accounts? || admin? || logistics?
  end
  def render_cancellation_form?
    admin? || accounts?
  end

  def cancel_ar_invoice?
    update?
  end

  def can_cancel_or_reject?
    admin? || accounts?
  end

  def download_eway_bill_format?
    edit?
  end
end
