class Overseers::CreditNotePolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted?
  end
end
