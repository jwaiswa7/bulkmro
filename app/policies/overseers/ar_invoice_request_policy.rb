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

  def can_create_outward_dispatch?
    (admin? || logistics?) && (record.status == 'Completed AR Invoice Request') && (!record.outward_dispatches.present? || (record.outward_dispatches.present? && (record.total_quantity_delivered > record.outward_dispatched_quantity)))
  end

  def download_eway_bill_format?
    edit?
  end

end
