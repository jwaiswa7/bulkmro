class Services::Shared::Migrations::AclMigrations < Services::Shared::BaseService

  def get_policies
    all_policies = {}
    Dir.glob("/var/www/html/sprint/app/policies/overseers/*") do |policy_file|
      data = File.read(policy_file)
      model = File.basename(policy_file, ".rb")
      policies = []
      policies = data.scan(/(?:def\ )(?:.*)/)
      all_policies[model.gsub('_policy','')] = policies.map {|x| x.gsub('def ','').gsub('?','')}
    end
    all_policies
  end


  def create_acl_roles

    all_acl_resources = Settings.acl.default_resources

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
  end

  def generate_resource_json

    all_policies = {}
    Dir.glob("/var/www/html/sprint/app/policies/overseers/*") do |policy_file|
      data = File.read(policy_file)
      model = File.basename(policy_file, ".rb")
      policies = []
      policies = data.scan(/(?:def\ )(?:.*)/)
      all_policies[model.gsub('_policy','')] = policies.map {|x| x.gsub('def ','').gsub('?','')}
    end

    all_acl = []
    id = 1
    default_controls = ['index','new','create','edit','update','show']

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
        if !default_controls.include?index.to_s
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
end
