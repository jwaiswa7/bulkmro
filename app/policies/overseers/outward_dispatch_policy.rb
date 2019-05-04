class Overseers::OutwardDispatchPolicy < Overseers::ApplicationPolicy

  def create_with_packing_slip?
    create?
  end

  def can_create_packing_slip?
    !record.packing_slips.present?
  end
end
