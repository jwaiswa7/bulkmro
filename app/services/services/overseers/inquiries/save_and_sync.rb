class Services::Overseers::Inquiries::SaveAndSync < Services::Shared::BaseService

  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    inquiry.save

    # sync
    if inquiry.synced?

      if !inquiry.project_uid.present?
        project = Resources::Project.create(Resources::Project.to_remote(inquiry))
        inquiry.project_uid = project.Code

      end


      if inquiry.opportunity_uid.present?
        #Resources::SalesOpportunity.update(inquiry.opportunity_uid, Resources::Opportunity.to_remote(inquiry))
      else
        opportunity =  Resources::SalesOpportunity.create(Resources::SalesOpportunity.to_remote(inquiry))
        inquiry.opportunity_uid = opportunity.SequentialNo

      end

      if inquiry.sales_quotes.any?
        if inquiry.quotation_uid.present?
          quotation = Resources::Quotation.update(inquiry.quotation_uid,Resources::Quotation.to_remote(inquiry))
        else

          quotation = Resources::Quotation.create(Resources::Quotation.to_remote(inquiry))
          inquiry.quotation_uid = quotation.U_MgntDocID

        end
      end

      inquiry.save
    end
  end

  attr_accessor :inquiry
end