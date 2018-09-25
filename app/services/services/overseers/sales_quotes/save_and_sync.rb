class Services::Overseers::SalesQuotes::SaveAndSync < Services::Shared::BaseService

  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    if sales_quote.save
      if Rails.env.development?
        call_later
      else
        perform_later(inquiry)
      end
    end
  end

  def call_later

      if sales_quote.quotation_uid.present?
        Resources::Quotation.update(sales_quote.quotation_uid, sales_quote)
      else
        sales_quote.quotation_uid = Resources::Quotation.create(sales_quote)
      end
  end

  attr_accessor :sales_quote
end