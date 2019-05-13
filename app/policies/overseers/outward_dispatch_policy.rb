class Overseers::OutwardDispatchPolicy < Overseers::ApplicationPolicy
  def create_with_packing_slip?
    create?
  end

  def can_create_packing_slip?
    (admin? || logistics?) && record.packing_slips.present? && (record.ar_invoice_request.total_quantity_delivered > record.quantity_in_payment_slips)
  end
  def index?
    admin? || logistics?
  end

  def show?
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

end
