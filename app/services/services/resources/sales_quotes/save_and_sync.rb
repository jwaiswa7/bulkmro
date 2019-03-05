class Services::Resources::SalesQuotes::SaveAndSync < Services::Shared::BaseService
  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    if sales_quote.save
      perform_later(sales_quote)
    end
  end

  def call_later
    if sales_quote.remote_uid.blank? && sales_quote.inquiry.quotation_uid.present? && sales_quote.parent.present? && sales_quote.parent.sales_orders.remote_approved.blank?
      sales_quote.remote_uid = sales_quote.inquiry.quotation_uid
    end

    if sales_quote.remote_uid.present?
      ::Resources::Quotation.update(sales_quote.remote_uid, sales_quote)
    else
      remote_uid = ::Resources::Quotation.create(sales_quote)
      sales_quote.update_attributes(remote_uid: remote_uid)
      sales_quote.inquiry.update_attributes(quotation_uid: remote_uid)
    end
  end

  attr_accessor :sales_quote
end
