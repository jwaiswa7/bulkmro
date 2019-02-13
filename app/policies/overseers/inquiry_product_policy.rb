

class Overseers::InquiryProductPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.inquiry_product_suppliers.blank? && record.sales_quote_rows.blank?
  end
end
