class Overseers::SalesQuotePolicy < Overseers::ApplicationPolicy
  def new_email_message?
    record.persisted? && record.sent? && record.children.blank? && overseer.can_send_emails?
  end

  def create_email_message?
    new_email_message?
  end

  def edit?
    record == record.inquiry.sales_quotes.latest_record && record.not_sent?
  end

  def new_revision?
    record == record.inquiry.sales_quotes.latest_record && record.persisted? && record.sent?
  end

  def new_sales_order?
    new_revision? && (record.inquiry.valid_for_new_sales_order? || dev?)
  end
end