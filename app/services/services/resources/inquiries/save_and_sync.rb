class Services::Resources::Inquiries::SaveAndSync < Services::Shared::BaseService
  def initialize(inquiry, now = false)
    @inquiry = inquiry
    @now = now
  end

  def call
    if inquiry.save
      if now 
        perfom_now(inquiry)
      else 
        perform_later(inquiry)
      end
    end
  end

  def call_later
    if inquiry.project_uid.blank?
      project_uid = ::Resources::Project.create(inquiry)
      inquiry.update_attributes(project_uid: project_uid)
    end

    if inquiry.opportunity_uid.present?
      # ::Resources::SalesOpportunity.update(inquiry.opportunity_uid, inquiry)
    else
      inquiry.update_attributes(opportunity_uid: ::Resources::SalesOpportunity.create(inquiry))
    end

    # if inquiry.attachment_uid.present?
    #   ::Resources::Attachment.update(inquiry.attachment_uid, inquiry)
    # elsif inquiry.has_attachment?
    #   inquiry.update_attributes(attachment_uid: ::Resources::Attachment.create(inquiry))
    # end

    if inquiry.final_sales_quote.present?
      inquiry.final_sales_quote.save_and_sync
    end
  end

  attr_accessor :inquiry, :now
end
