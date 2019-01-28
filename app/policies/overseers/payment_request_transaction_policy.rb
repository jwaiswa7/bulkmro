class Overseers::PaymentRequestTransactionPolicy < Overseers::ApplicationPolicy
  def destroy?
    accounts? || admin?
  end

  def disabled_fields?
    logistics?
  end
end