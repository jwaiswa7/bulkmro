class Overseers::OutwardDispatchPolicy < Overseers::ApplicationPolicy

  def create_with_packing_slip?
    create?
  end

  def can_create_packing_slip?
    (admin? || logistics?) && record.packing_slips.present? && (record.ar_invoice_request.total_quantity_delivered > record.quantity_in_payment_slips)
  end
end
