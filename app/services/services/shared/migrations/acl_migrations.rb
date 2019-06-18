class Services::Shared::Migrations::AclMigrations < Services::Shared::BaseService

  @not_applicable_resource_models = ['acl_resource', 'acl_role', 'activity', 'activity_overseer', 'address_state', 'application', 'application_record', 'attachment', 'average_cache', 'bank', 'bible_sales_order', 'brand', 'brand_supplier', 'callback_request', 'cart', 'cart_item', 'category', 'category_supplier', 'chat_message', 'company_bank', 'company_contact', 'company_creation_request', 'company_rating', 'company_review', 'contact', 'contact_creation_request', 'currency', 'currency_rate', 'customer_order_approval', 'customer_order_rejection', 'customer_order_row', 'customer_product_import', 'customer_product_import_row', 'customer_product_tag', 'dashboard', 'doc', 'document_creation', 'email_message', 'export', 'extensions', 'freight_quote_comment', 'freight_request_comment', 'ifsc_code', 'image_reader', 'industry', 'inquiry_comment', 'inquiry_currency', 'inquiry_import', 'inquiry_import_row', 'inquiry_mapping_tat', 'inquiry_product', 'inquiry_product_supplier', 'inquiry_status_record', 'invoice_request', 'invoice_request_comment', 'inward_dispatch', 'inward_dispatch_comment', 'inward_dispatch_row', 'kit_product_row', 'lead_time_option', 'measurement_unit', 'mpr_row', 'notification', 'overall_average', 'payment_collection_emails', 'payment_option', 'payment_request', 'payment_request_comment', 'payment_request_transaction', 'po_comment', 'pod_row', 'po_request_comment', 'po_request_row', 'product_approval', 'product_comment', 'product_rejection', 'product_supplier', 'profile', 'purchase_order_row', 'rate', 'rating_cache', 'report', 'sales_invoice_row', 'sales_order_approval', 'sales_order_comment', 'sales_order_confirmation', 'sales_order_rejection', 'sales_order_row', 'sales_purchase_order', 'sales_quote', 'sales_quote_row', 'sales_receipt', 'sales_receipt_row', 'sales_shipment', 'sales_shipment_comment', 'sales_shipment_package', 'sales_shipment_row', 'sprint_log', 'tag', 'target', 'target_period', 'tax_code']

  @default_resource_list = []

  # 1. Create acl resources for all models with default actions
  def create_acl_resource_for_all_models
    default_actions = ['index', 'new', 'edit', 'create', 'update', 'destroy', 'show']
    overseer = Overseer.find(153)
    Dir.foreach("#{Rails.root}/app/models") do |model_path|
      model_name = File.basename(model_path, ".rb")
      if model_name.present? && model_name != '.' && model_name != '..'
        default_actions.each do |action|
          AclResource.where(:resource_model_name => model_name, :resource_action_name => action).first_or_create! do |acl_res|
            acl_res.assign_attributes(:overseer => overseer)
          end
        end
      end
    end
  end

  # 2. Create acl resources for all policies
  def create_acl_resources
    current_acl_resources = Settings.acl.default_resources
    parsed_json = ActiveSupport::JSON.decode(current_acl_resources)
    overseer = Overseer.find(153)
    parsed_json.each do |model|
      model['children'].each do |resource|
        AclResource.where(:resource_model_name => model['text'], :resource_action_name => resource['text']).first_or_create! do |acl_res|
          acl_res.assign_attributes(:overseer => overseer)
        end
      end
    end
  end


  # 3. Create roles and assign role resources
  #
  def create_new_roles
    # AclRole.all.destroy_all

    # Create admin role with all permissions
    acl_role = AclRole.where(:role_name => 'Admin').first_or_create!
    role_resources = AclResource.all.pluck(:id)
    resources = []
    role_resources.map {|x| resources << x.to_s}
    acl_role.role_resources = resources.uniq.to_json
    acl_role.save

    #Read sheet and create other roles
    service = Services::Shared::Spreadsheets::CsvImporter.new('acl_roles_permissions.csv', 'seed_files_3')
    role_resources = []
    last_role_name = nil
    service.loop(nil) do |x|
      resource_model = x.get_column('model')
      resource_action = x.get_column('action')
      role_name = x.get_column('role_name')
      is_permitted = x.get_column('permission')

      if last_role_name.present? && last_role_name != role_name
        resources = []
        role_resources.map {|x| resources << x.to_s}
        acl_role = AclRole.where(:role_name => last_role_name).first_or_create!
        acl_role.role_resources = resources.uniq.to_json
        acl_role.save
        role_resources = []
      end

      if is_permitted.present? && is_permitted == 'Yes'
        role_resources << AclResource.where(:resource_model_name => resource_model, :resource_action_name => resource_action).pluck(:id).first

        #if current resource_action is create or update, then assign permission to edit and new
        if resource_action == 'create'
          role_resources << AclResource.where(:resource_model_name => resource_model, :resource_action_name => 'new').pluck(:id).first
        elsif resource_action == 'update'
          role_resources << AclResource.where(:resource_model_name => resource_model, :resource_action_name => 'edit').pluck(:id).first
        end
      end

      last_role_name = role_name
    end

    #last role
    resources = []
    role_resources.map {|x| resources << x.to_s}
    acl_role = AclRole.where(:role_name => last_role_name).first_or_create!
    acl_role.role_resources = resources.uniq.to_json
    acl_role.save

  end

  #4 Set default resources to all roles
  def set_default_resources_to_all_roles
    AclRole.where.not(:role_name => 'Default - Read Only').each do |role|
      resources = []
      role_resources = ActiveSupport::JSON.decode(role.role_resources)
      role_resources << get_default_resource_list
      role_resources.map {|x| resources << x.to_s}
      role_resources = resources.uniq
      role.role_resources = role_resources.to_json
      role.save
    end
  end

  # 6
  def set_super_admins
    overseers = ['pradeep.ketkale@bulkmro.com', 'bhargav.trivedi@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com']
    overseers.each do |email|
      overseer = Overseer.find_by_email(email)
      overseer.is_super_admin = 1
      overseer.acl_role_id = 1
      overseer.save
    end
  end

  #7 - assign roles to overseers

  def assign_roles_to_overseers
    service = Services::Shared::Spreadsheets::CsvImporter.new('overseer_roles.csv', 'seed_files_3')

    service.loop(nil) do |x|
      id = x.get_column('id')
      role_name = x.get_column('role')
      overseer = Overseer.where(id: id).first if id.present?

      if overseer.present?
        acl_role = AclRole.where(:role_name => role_name).first
        overseer.acl_role = acl_role
        overseer.acl_resources = ActiveSupport::JSON.decode(acl_role.role_resources).to_json
        overseer.save
      end
    end
  end

  # 8. Assign all resources to developers/admins
  def assign_all_resources_to_devs
    overseer = Overseer.find(153)
    admin_acl_role = AclRole.find_by_role_name('Admin')
    overseers = ['pradeep.ketkale@bulkmro.com', 'bhargav.trivedi@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com', 'ruta.kambli@bulkmro.com', 'meenakshi.naik@bulkmro.com', 'sourabh.raje@bulkmro.com', 'saurabh.bhosale@bulkmro.com', 'sakshi.yadav@bulkmro.com', 'lopesh.durugkar@bulkmro.com', 'sufiyan.siddique@bulkmro.com', 'kunal.sheth@bulkmro.com', 'suganya.murugan@bulkmro.com']

    overseers.each do |overseer_email|
      o = Overseer.find_by_email(overseer_email)
      puts overseer_email
      allowed_resources = []
      AclResource.all.each do |acl_resource_model|
        allowed_resources << acl_resource_model.id.to_s
      end
      o.update_attributes!(:acl_resources => allowed_resources.to_json, :acl_role => admin_acl_role) if o.present?
    end
  end

  #5 Create default role with read-only access
  def create_default_role
    overseer = Overseer.find(153)
    resource_ids = []

    Dir.foreach("#{Rails.root}/app/models") do |model_path|
      model_name = File.basename(model_path, ".rb")
      if model_name.present? && model_name != '.' && model_name != '..'
        resource_ids << AclResource.where('resource_model_name = ? and resource_action_name in (?, ?)', model_name, 'index', 'show').pluck(:id)
      end
    end

    read_only_resource_ids = []
    resource_ids.map {|x| x.map {|y| read_only_resource_ids << y.to_s}}
    read_only_resource_ids = read_only_resource_ids.uniq

    ar = AclRole.where(:role_name => 'Default - Read Only').first_or_create!
    ar.role_resources = read_only_resource_ids.to_json
    ar.created_by = overseer
    ar.updated_by = overseer
    ar.save

  end

  def get_default_resource_list
    resource_ids = []
    not_applicable_resource_models = ['address_state', 'application', 'application_record', 'attachment', 'average_cache', 'bank', 'bible_sales_order', 'brand', 'brand_supplier', 'chat_message', 'currency', 'currency_rate', 'customer_order_approval', 'customer_order_rejection', 'customer_order_row', 'customer_product_import', 'customer_product_import_row', 'customer_product_tag', 'dashboard', 'doc', 'document_creation', 'email_message', 'export', 'extensions', 'ifsc_code', 'image_reader', 'industry', 'inquiry_comment', 'inquiry_currency', 'inquiry_import', 'inquiry_import_row', 'inquiry_mapping_tat', 'inquiry_product', 'inquiry_product_supplier', 'inquiry_status_record', 'invoice_request_comment', 'inward_dispatch_comment', 'inward_dispatch_row', 'kit_product_row', 'mpr_row', 'notification', 'overall_average', 'payment_request_comment', 'payment_request_transaction', 'po_comment', 'pod_row', 'po_request_comment', 'product_comment', 'profile', 'purchase_order_row', 'rate', 'rating_cache', 'report', 'sales_invoice_row','sales_order_comment', 'sales_order_row', 'sales_purchase_order', 'sales_quote_row', 'sales_receipt_row',  'sales_shipment_comment', 'sales_shipment_package', 'sales_shipment_row', 'sprint_log', 'tag', 'target', 'target_period', 'tax_code']

    not_applicable_resource_models.each do |na_model|
      resource_ids << AclResource.where(resource_model_name: na_model).pluck(:id)
    end

    access_to_default_resource_ids = []
    resource_ids.map {|x| x.map {|y| access_to_default_resource_ids << y.to_s}}
    access_to_all_resource_ids = access_to_default_resource_ids.uniq
    @default_resource_list = access_to_all_resource_ids
  end

  #NOT USED ANYMORE
  def create_acl_roles

    roles = [
        'left',
        'admin',
        'inside_sales_executive',
        'inside_sales_manager',
        'outside_sales_executive',
        'outside_sales_manager',
        'outside_sales_team_leader',
        'inside_sales_team_leader',
        'procurement',
        'accounts',
        'logistics',
        'cataloging',
        'hr'
    ]

    all_resources = AclResource.all.pluck(:id)
    all_resources = all_resources.map {|x| x.to_s}

    roles.each do |role|
      AclRole.where(:role_name => role).first_or_create! do |ar|
        ar.update_attributes(:role_resources => all_resources.to_json)
      end
    end

    #update role
    roles.each do |role|
      ar = AclRole.where(:role_name => role).first
      if ar.present?
        ar.role_resources = all_resources.to_json
        ar.save
      end
    end
  end

  def get_policies
    all_policies = {}
    Dir.glob("#{Rails.root}/app/policies/overseers/*") do |policy_file|
      data = File.read(policy_file)
      model = File.basename(policy_file, ".rb")
      policies = []
      policies = data.scan(/(?:def\ )(?:.*)/)
      all_policies[model.gsub('_policy', '')] = policies.map {|x| x.gsub('def ', '').gsub('?', '')}
    end
    all_policies
  end

  def generate_resource_json

    all_policies = {}
    Dir.glob("#{Rails.root}/app/policies/overseers/*") do |policy_file|
      data = File.read(policy_file)
      model = File.basename(policy_file, ".rb")
      policies = []
      policies = data.scan(/(?:def\ )(?:.*)/)
      all_policies[model.gsub('_policy', '')] = policies.map {|x| x.gsub('def ', '').gsub('?', '')}
    end

    all_acl = []
    id = 1
    default_controls = ['index', 'new', 'create', 'edit', 'update', 'show']

    all_policies.each do |resource_name, access_controls|
      temp_acl = OpenStruct.new
      temp_acl.id = id
      temp_acl.text = resource_name
      temp_acl.checked = false
      temp_acl.hasChildren = true
      children = []

      default_controls.each do |index, control_name|
        id = id + 1
        acl_row = OpenStruct.new
        acl_row.id = id
        acl_row.text = index
        acl_row.checked = false
        acl_row.hasChildren = false
        children.push(acl_row.marshal_dump)
      end

      access_controls.each do |index, control_name|
        if !default_controls.include? index.to_s
          id = id + 1
          acl_row = OpenStruct.new
          acl_row.id = id
          acl_row.text = index
          acl_row.checked = false
          acl_row.hasChildren = false
          children.push(acl_row.marshal_dump)
        end
      end

      temp_acl.children = children
      all_acl.push(temp_acl.marshal_dump)
      id = id + 1
    end

    puts all_acl.to_json
  end

  def get_controller_action_list
    controllers = []
    routes = Rails.application.routes.routes.map do |route|
      controllers << [route.name, route.path.spec.to_s, route.defaults[:controller], route.defaults[:action]].join('===')
    end
    routes
  end

  def get_view_file_list
    view_files = []
    Dir.glob("/var/www/html/sprint/app/views/overseers/*") do |view_file|
      view_files << view_file
    end
  end

  def get_model_action
    model_actions = []
    AclResource.all.order(resource_model_name: :asc).each do |acl_resource|
      model_actions << [acl_resource.resource_model_name, acl_resource.resource_action_name]
    end
    model_actions
  end

end
