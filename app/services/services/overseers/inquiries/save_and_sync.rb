class Services::Overseers::Inquiries::SaveAndSync < Services::Shared::BaseService

  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    inquiry.sales_manager = Overseer.all.sample
    if inquiry.save
      call_later
      #perform_later(inquiry)
    end
  end

  def call_later
    if inquiry.project_uid.blank?
      inquiry.project_uid = Resources::Project.create(inquiry)
    end

    if inquiry.opportunity_uid.present?
      # Resources::SalesOpportunity.update(inquiry.opportunity_uid, inquiry)
    else
      inquiry.opportunity_uid =  Resources::SalesOpportunity.create(inquiry)
    end

    if inquiry.sales_quotes.any?
        sales_quote = inquiry.sales_quotes.last
        if sales_quote.quotation_uid.present?
          # Resources::Quotation.update(inquiry.quotation_uid, inquiry)
        else
          sales_quote.quotation_uid = Resources::Quotation.create(sales_quote)
        end

    end
  end

  attr_accessor :inquiry
end