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
    new_revision? && record.inquiry.synced? && record.synced? && record.inquiry.valid_for_new_sales_order? && record.email_messages.present? && record.sales_quote_quantity_not_fulfilled? && (record.inquiry.last_synced_quote_id.present? && (record.inquiry.final_sales_quote.id == record.inquiry.last_synced_quote_id))
  end

  def reset_quote?
    developer?
  end

  def preview?
    edit?
  end

  def new_freight_request?
    !record.freight_request.present? && record.is_final? && !logistics?
  end
end
