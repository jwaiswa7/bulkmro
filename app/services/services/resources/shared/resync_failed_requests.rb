class Services::Resources::Shared::ResyncFailedRequests < Services::Shared::BaseService
  def initialize(resync_request)
    @resync_request = resync_request
    @model = resync_request.subject

    @item_errors = [
        # "Item code "
        'already exists',
        'Invalid session.',
        '(1000) Item Name Already Exist For Another Item Code.',
        "You cannot change the inventory item category; item has been used in one or more transactions  [OITM.InvntItem] , 'BM9A6A7'"
    ]

    @project_errors = [
        'This entry already exists in the following tables (ODBC -2035)'
    ]

    @business_partner_errors = [
        "1320000140 - Business partner code 'SC-208615' already assigned to a business partner; enter a unique business partner code",
        'Invalid session.',
        'This entry already exists in the following tables (ODBC -2035)',
        'Another user or another operation modified data; to continue, open the window again (ODBC -2039)',
        'Enter valid code ',
        'Deleting rows not supported for object Fiscal IDs for BP Master Data',
        '(1000) Business Partner Already Exist.',
        '10000908 - Enter P.A.N. number for business partner',
        "1250000128 - No state found for pay-to address 'A210486'; on the Addresses tab, define state information [BPAddresses.State]",
        "1250000126 - No state found for ship-to address 'A207508'; on the Addresses tab, define state information [BPAddresses.State]"
    ]
  end

  def call
    if resync_request.hits <= 5
      case resync_request.resource
      when 'EmployeesInfo'
        # resync_employee
      when 'ProductTrees'
        # resync_product_tree
      when 'Items'
        resync_products
      when 'BusinessPartnerGroups'
        # resync_bp_group
      when 'Projects'
        resync_project
      when 'SalesOpportunities'
        # resync_opportunity
      when 'Quotations'
        # resync_bp_group
        if resync_request.error_message.include?('Field cannot be updated (ODBC -1029)')
          # reset_quote ?
        elsif resync_request.error_message.include?('No matching records found (ODBC -2028)')
          resync_project
          resync_products
          resync_business_partners
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
        # when 'PaymentTermsTypes'
      end
    end
  end

  def resync_products
    5.times do
      if resync_request.subject_type == 'Inquiry'
        error = resync_request.error_message
        # if item_errors.include?(error)
        model.inquiry_products.each do |ip|
          item_code = ::Resources::Item.custom_find_resync(["#{ip.sku}", 'ItemCode'])
          model.update_attributes(remote_uid: item_code)
        end
        resync_request.update_attributes(hits: resync_request.hits + 1)
        # end
      elsif resync_request.subject_type == 'Product'
        item_code = ::Resources::Item.custom_find_resync(["#{model.sku}", 'ItemCode'])
        model.update_attributes(remote_uid: item_code)
        resync_request.update_attributes(hits: resync_request.hits + 1)
      end
    end if resync_request.status == "failed"
  end

  def resync_project
    5.times do
      error = resync_request.error_message
      if project_errors.include?(error)
        project_uid = ::Resources::Project.custom_find_resync(model.inquiry_number, 'Code', resync_request)
        if project_uid != false && project_uid.to_i > 0
          model.update_attributes(project_uid: project_uid)
          resync_request.update_attributes(hits: resync_request.hits + 1)
          break
        end
      end
    end
  end

  def resync_business_partners
    5.times do
      remote_uid = ::Resources::BusinessPartner.custom_find_resync(model.remote_uid, 'CardCode')
      if remote_uid.present?
        ::Resources::BusinessPartner.update_associated_records(remote_uid)
        resync_request.update_attributes(hits: resync_request.hits + 1)
      end
    end
  end

  # def reset_quote
  #   model.inquiry.quotation_uid = nil
  # end

  attr_accessor :resync_request, :model, :item_errors, :project_errors
end
