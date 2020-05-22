class Overseers::OutwardDispatchPolicy < Overseers::ApplicationPolicy
  def create_with_packing_slip?
    create?
  end

  def can_create_packing_slip?
    sales_invoice = record.sales_invoice
    (sales_invoice.total_quantity_delivered != sales_invoice.outward_dispatches.sum(&:quantity_in_payment_slips))
  end
  def index?
    admin? || logistics?
  end


  def new?
    admin? || logistics?
  end

  def create?
    admin? || logistics?
  end

  def edit?
    admin? || logistics?
  end

  def update?
    admin? || logistics?
  end

  def dispatch_mail_to_customer?
    admin? || logistics?
    end
  def dispatch_mail_to_customer_notification?
    dispatch_mail_to_customer?
  end
end
