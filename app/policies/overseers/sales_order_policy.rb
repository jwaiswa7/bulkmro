class Overseers::SalesOrderPolicy < Overseers::ApplicationPolicy
  def show?
    record.persisted? && record.order_number.present? && !record.serialized_pdf.attached?
  end

  def show_serialized?
    record.serialized_pdf.attached?
  end

  def edit?
    record == record.sales_quote.sales_orders.latest_record && record.not_sent? && record.not_approved?
  end

  def new_confirmation?
    edit?
  end

  def create_confirmation?
    person?
  end

  def new_revision?
    record.persisted? && record.sent? && record.rejected?
  end

  def comments?
    record.persisted?
  end

  def pending?
    manager?
  end

  def go_to_inquiry?
    record.inquiry.can_be_managed_by(overseer)
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
      scope.all
    end
  end

end