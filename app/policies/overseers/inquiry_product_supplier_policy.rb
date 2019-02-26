# frozen_string_literal: true

class Overseers::InquiryProductSupplierPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.sales_quote_rows.blank?
  end
end
