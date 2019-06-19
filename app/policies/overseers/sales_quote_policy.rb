# frozen_string_literal: true

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

  def display_revision_button?
    new_revision? && !record.so_status_req_or_pending.present?
  end

  def new_sales_order?
    new_revision? && record.inquiry.synced? && record.synced? && record.inquiry.valid_for_new_sales_order? && record.email_messages.present? && record.sales_quote_quantity_not_fulfilled? && (record.inquiry.last_synced_quote_id.present? && (record.inquiry.final_sales_quote.id == record.inquiry.last_synced_quote_id))
  end

  def reset_quote?
    developer? && record == record.inquiry.final_sales_quote
  end

  def reset_quote_for_manager?
    record == record.inquiry.final_sales_quote && (['nilesh.desai@bulkmro.com', 'lavanya.jamma@bulkmro.com'].include? overseer.email)
  end

  def preview?
    edit?
  end

  def new_freight_request?
    !record.freight_request.present? && record.is_final? && !logistics?
  end

  def relationship_map?
    all_roles?
  end

  def reset_quote_form?
    (['nilesh.desai@bulkmro.com', 'lavanya.jamma@bulkmro.com'].include? overseer.email)
  end

  def sales_quote_reset_by_manager?
    reset_quote_form?
  end

  def get_relationship_map_json?
    relationship_map?
  end
end
