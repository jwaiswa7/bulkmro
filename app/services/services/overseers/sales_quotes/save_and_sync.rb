class Services::Overseers::SalesQuotes::SaveAndSync < Services::Shared::BaseService

  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    if sales_quote.save!
      perform_later(sales_quote)
    end
  end

  def call_later
    if sales_quote.inquiry.project_uid.blank?
      sales_quote.inquiry.project_uid = Resources::Project.create(sales_quote.inquiry)
    end
    sales_quote.inquiry.save

    if sales_quote.inquiry.opportunity_uid.present?
      # Resources::SalesOpportunity.update(sales_quote.inquiry.opportunity_uid, sales_quote.inquiry)
    else
      sales_quote.inquiry.opportunity_uid = Resources::SalesOpportunity.create(sales_quote.inquiry)
    end
    sales_quote.inquiry.save

    if sales_quote.persisted?
      if sales_quote.quotation_uid.present?
        Resources::Quotation.update(sales_quote.quotation_uid, sales_quote)
      else
        sales_quote.quotation_uid = Resources::Quotation.create(sales_quote)
        sales_quote.save
      end
    end
  end

  attr_accessor :sales_quote
end