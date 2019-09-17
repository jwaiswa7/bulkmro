# frozen_string_literal: true

class Suppliers::ApplicationPolicy
  attr_reader :contact, :current_company, :record

  def initialize(contact, current_company, record)
    @contact = contact
    @current_company = current_company
    @record = record
  end

  def autocomplete?
    true
  end

  def supplier?
    contact.supplier?
  end

  def show?
    true
  end

  def index?
    true
  end

  def new?
    true
  end

  def create?
    new?
  end

  def edit?
    true
  end

  def update?
    edit?
  end

  def destroy?
    update?
  end

  def scope
    Pundit.policy_scope!(contact, record.class)
  end

  class Scope
    attr_reader :contact, :scope

    def initialize(contact, scope)
      @contact = contact
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
