# frozen_string_literal: true

class Overseers::InquiryProductSupplierPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.sales_quote_rows.blank?
  end

  def request_for_quote?
    record.supplier.contacts.present?
  end
end
