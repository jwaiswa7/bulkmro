class RemoteRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

  update_index('remote_requests#remote_request') {self}

  pg_search_scope :locate, :against => [:url], :associated_against => {}, :using => { :tsearch => { :prefix => true } }

  def manage_remote_request_data(remote_request)
    case remote_request.resource
    when "Quotations"
      if remote_request.request.has_key?('Project')
        remote_request.request['Project']
      end
    when "Projects"
      if remote_request.request.has_key?('Code')
        remote_request.request['Code']
      end
    end
  end

  enum resources:{
    :'Projects' => 10,
    :'EmployeesInfo' => 20,
    :'ProductTrees' => 30,
    :'BusinessPartnerGroups' => 40,
    :'SalesOpportunities' => 50,
    :'SalesPersons' => 60,
    :'Manufacturers' => 70,
    :'PaymentTermsTypes' => 80,
    :'Quotations' => 90,
    :'BusinessPartners' => 100,
    :'Drafts' => 110,
    :'ItemGroups' => 120,
    :'Invoices' => 130,
    :'Attachments2' => 140,
    :'Items' => 150
  }

  scope :with_includes, -> {}
end
