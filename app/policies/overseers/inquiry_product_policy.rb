class Overseers::InquiryProductPolicy < Overseers::ApplicationPolicy
  def destroy?
    self.inquiry_product_suppliers.blank? && self.sales_quote_rows.blank?
  end
end