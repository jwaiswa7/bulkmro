class Overseers::ContactCreationRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || cataloging?
  end

  def requested?
    index?
  end

  def created?
    index?
  end

  def exchange_with_existing_contact?
    index?
  end
end
