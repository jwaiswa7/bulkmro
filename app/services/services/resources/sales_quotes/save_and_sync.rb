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
    if sales_quote.quotation_uid.present?
      ::Resources::Quotation.update(sales_quote.quotation_uid, sales_quote)
    else
      sales_quote.inquiry.update_attributes(quotation_uid: ::Resources::Quotation.create(sales_quote))
    end
  end

  attr_accessor :sales_quote
end
