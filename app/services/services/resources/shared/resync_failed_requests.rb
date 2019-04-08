class Services::Resources::Shared::ResyncFailedRequests < Services::Shared::BaseService
  def initialize(resync_request)
    @resync_request = resync_request
    @model = resync_request.subject
  end

  def call
    case resync_request.resource
    when 'EmployeesInfo'
      # resync_employee
    when 'ProductTrees'
      # resync_product_tree
    when 'BusinessPartnerGroups'
      # resync_bp_group
    when 'Projects'
      resync_projects
    when 'SalesOpportunities'
      # resync_opportunity
    when 'Quotations'
      # resync_bp_group
    when 'BusinessPartners'
      # resync_bp_group
    when 'Drafts'
      # resync_bp_group
      # when 'ItemGroups'
      # when 'SalesPersons'
      # when 'Manufacturers'
      # when 'Invoices'
      # when 'Attachments2'
      # when 'Items'
      # when 'PaymentTermsTypes'
    end
  end

  def resync_projects
    case resync_request.error_message
    when 'This Entry Already Exists'
      5.times do
        project_uid = ::Resources::Project.custom_find_resync(["#{model.inquiry_number} - ", model.subject[0..50]].join, 'Name')
        if !project_uid
          model.update_attributes(project_uid: project_uid)
          break
        end
      end
    end
  end

  attr_accessor :resync_request, :model
end
