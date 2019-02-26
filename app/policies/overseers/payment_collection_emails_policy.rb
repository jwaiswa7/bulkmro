class Overseers::PaymentCollectionEmailsPolicy < Overseers::ApplicationPolicy
  def new?
    overseer.can_send_emails?
  end
  def create?
    overseer.can_send_emails?
  end
end