class Customers::ApplicationPolicy
  attr_reader :contact, :record

  def initialize(contact, record)
    @contact = contact
    @record = record
  end

  def customer?
    contact.customer?
  end

  def show?
    true
  end

  # def scope
  #   Pundit.policy_scope!(contact, record.class)
  # end
  #
  # class Scope
  #   attr_reader :contact, :scope
  #
  #   def initialize(contact, scope)authorize :dashboard, :show?
  #   @contact = contact
  #   @scope = scope
  #   end
  #
  #   def resolve
  #     scope
  #   end
  # end
end