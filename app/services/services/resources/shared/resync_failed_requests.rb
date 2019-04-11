class Services::Resources::Shared::ResyncFailedRequests < Services::Shared::BaseService
  def initialize(resync_request)
    @resync_request = resync_request
    @model = resync_request.subject

    @item_errors = [
        "Item code 'BM9T0Q8' already exists",
        'Invalid session.',
        '(1000) Item Name Already Exist For Another Item Code.',
        "You cannot change the inventory item category; item has been used in one or more transactions  [OITM.InvntItem] , 'BM9A6A7'"
    ]

    @project_errors = [
        "Invalid session.",
        "This entry already exists in the following tables (ODBC -2035)"
    ]
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
      resync_project
    when 'SalesOpportunities'
      # resync_opportunity
    when 'Quotations'
      # resync_bp_group
      if resync_request.error_message.include?('No matching records found (ODBC -2028)')
        resync_products
        resync_project
      elsif resync_request.error_message.include?('Field cannot be updated (ODBC -1029)')
        resync_quotation
      end
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

  def resync_products
    case error = resync_request.error_message
    when item_errors.include?(error)
      model.inquiry_products.each do |ip|
        item_code = ::Resources::Item.custom_find_resync(["#{ip.sku}", 'ItemCode'])
      end
    end
  end

  def resync_project
    error = resync_request.error_message
    if project_errors.include?(error)
      project_uid = ::Resources::Project.custom_find_resync(model.inquiry_number, 'Code', resync_request)
      if !project_uid
        model.update_attributes(project_uid: project_uid)
      end
    end
  end

  def resync_quotation
        # todo
       remote_uid_uid = ::Resources::Quotation.custom_find_resync(["#{model.inquiry_number} - ", model.subject[0..50]].join, 'DocEntry')
      if !remote_uid
        model.update_attributes(remote_uid: remote_uid)
      end
  end

  attr_accessor :resync_request, :model, :item_errors, :project_errors
end
