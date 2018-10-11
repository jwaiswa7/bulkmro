class Overseers::SalesOrderPolicy < Overseers::ApplicationPolicy
  def edit?
    record == record.sales_quote.sales_orders.latest_record && record.not_sent? && record.not_approved?
  end

  def new_confirmation?
    edit?
  end

  def create_confirmation?
    sales?
  end

  def new_revision?
    record.persisted? && record.sent? && record.rejected?
  end

  def comments?
    record.persisted?
  end

  def pending?
    sales_manager?
  end

  def go_to_inquiry?
    admin?
  end

  def approve?
    pending? && record.sent? && record.not_approved? && !record.rejected?
  end

  def reject?
    record.sent? && approve?
  end

  def resync?
    record.sent? && record.approved? && record.not_synced?
  end

  class Scope
    attr_reader :overseer, :scope

    def initialize(overseer, scope)
      @overseer = overseer
      @scope = scope
    end

    def resolve
      if overseer.admin?
        scope.all
      else
        scope.where(:created_by => overseer.self_and_descendants)
      end
    end
  end

end