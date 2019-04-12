class Overseers::PaymentRequestTransactionPolicy < Overseers::ApplicationPolicy
  def destroy?
    accounts? || logistics? || admin?
  end

  def disabled_fields?
    logistics?
  end
end
