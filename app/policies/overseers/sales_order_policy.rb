class Overseers::SalesOrderPolicy < Overseers::ApplicationPolicy
  def edit?
    record == record.sales_quote.sales_orders.latest_record && record.not_sent?
  end

  def confirmation?
    edit?
  end

  def new_revision?
    record.persisted? && record.sent? && record.rejected?
  end

  def pending?
    admin?
  end

  def go_to_inquiry?
    admin?
  end

  def approve?
    record.sent? && record.not_approved? && !record.rejected?
  end

  def reject?
    record.sent? && approve?
  end

  def comments?
    record.persisted?
  end
end