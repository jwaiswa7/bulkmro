class Overseers::PurchaseOrderPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.not_legacy? && !record.document.attached?
  end

  def export_all?
    admin?
  end

  def show_document?
    record.document.attached?
  end
end