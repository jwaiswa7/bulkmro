class Services::Shared::Migrations::AclMigrations < Services::Shared::BaseService

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

  def create_acl_roles

    resource_json = []
    models = []
    children = []
    acl_parent = []

    AclResource.all.order(resource_model_name: :asc).each do |acl_resource|
      if !models.include? acl_resource.resource_model_name
        if children.present? && children.size > 0
          acl_parent.children = children
          resource_json.push(acl_parent.marshal_dump)
          children = []
        end

        models << acl_resource.resource_model_name

        #Parent Node
        acl_parent = OpenStruct.new
        acl_parent.id = acl_resource.id
        acl_parent.text = acl_resource.resource_model_name
        acl_parent.checked = false
        acl_parent.hasChildren = true

        #First Child Node
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_name
        acl_row.checked = false
        acl_row.hasChildren = false
        children.push(acl_row.marshal_dump)

      else
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_name
        acl_row.checked = false
        acl_row.hasChildren = false
        children.push(acl_row.marshal_dump)
      end
    end

    #Last child node
    if children.present? && children.size > 0
      acl_parent.children = children
      resource_json.push(acl_parent.marshal_dump)
      children = []
    end


    all_acl_resources = resource_json.to_json

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

    roles.each do |role|
      AclRole.where(:role_name => role).first_or_create! do |ar|
        ar.update_attributes(:role_resources => all_acl_resources)
      end
    end

    #update role
    roles.each do |role|
      ar = AclRole.where(:role_name => role).first
      if ar.present?
        ar.role_resources = all_acl_resources
        ar.save
      end
    end
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

  def set_super_admins
    overseers = ['pradeep.ketkale@bulkmro.com', 'bhargav.trivedi@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com']
    overseers.each do |email|
      overseer = Overseer.find_by_email(email)
      overseer.is_super_admin = 1
      overseer.acl_role_id = 1
      overseer.save
    end
  end

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

  def assign_all_resources_to_devs
    overseer = Overseer.find(153)
    admin_acl_role = AclRole.find_by_role_name('admin')
    overseers = ['pradeep.ketkale@bulkmro.com', 'bhargav.trivedi@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com', 'ruta.kambli@bulkmro.com', 'meenakshi.naik@bulkmro.com', 'sourabh.raje@bulkmro.com', 'saurabh.bhosale@bulkmro.com', 'sakshi.yadav@bulkmro.com', 'lopesh.durugkar@bulkmro.com', 'sufiyan.siddique@bulkmro.com', 'rucha.parab@bulkmro.com', 'kunal.sheth@bulkmro.com','suganya.murugan@bulkmro.com']


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
end
