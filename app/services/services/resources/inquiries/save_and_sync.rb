class Services::Resources::Inquiries::SaveAndSync < Services::Shared::BaseService

  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    if inquiry.save!
      perform_later(inquiry)
    end
  end

  def call_later
    if inquiry.project_uid.blank?
      project_uid = ::Resources::Project.create(inquiry)

      if(project_uid == nil)
        project_uid = ::Resources::Project.find_by_name(inquiry.subject)
      end

      inquiry.project_uid = project_uid
    end
    inquiry.save
    if inquiry.opportunity_uid.present?
      ::Resources::SalesOpportunity.update(inquiry.opportunity_uid, inquiry)
    else
      inquiry.opportunity_uid = ::Resources::SalesOpportunity.create(inquiry)
    end
    inquiry.save
    if inquiry.sales_quotes.any?
      sales_quote = inquiry.final_sales_quote
      sales_quote.save_and_sync if sales_quote.present?
    end

  end

  attr_accessor :inquiry
end