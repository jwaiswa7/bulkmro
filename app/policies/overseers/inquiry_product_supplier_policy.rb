# frozen_string_literal: true

class Overseers::InquiryProductSupplierPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.sales_quote_rows.blank?
  end

  def request_for_quote?
    record.supplier.contacts.present?
  end

  def update_and_send_link?
    record.supplier.default_contact.present? if record.supplier.present?
  end
end
