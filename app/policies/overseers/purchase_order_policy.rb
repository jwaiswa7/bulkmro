class Overseers::PurchaseOrderPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && !record.document.attached?
  end

  def show_document?
    record.document.attached?
  end
end