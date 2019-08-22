class AclResource < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, against: [:resource_model_name, :resource_action_name], using: {tsearch: {prefix: true}}

  after_save :update_acl_resource_cache

  def resource_action_alias_name
    if self.resource_action_alias.present?
      self.resource_action_alias
    else
      self.resource_action_name
    end
  end

  def resource_model_alias_name
    if self.resource_model_alias.present?
      self.resource_model_alias
    else
      self.resource_model_name
    end
  end

  def update_acl_resource_cache
    Rails.cache.delete('acl_resource_json')

    Rails.cache.fetch('acl_resource_json', expires_in: 3.hours) do
      AclResource.acl_resource_json
    end
    self.update_acl_menu_resource_cache
    self.update_acl_resource_ids_cache
  end

  def update_acl_menu_resource_cache
    Rails.cache.delete('acl_menu_resource_json')

    Rails.cache.fetch('acl_menu_resource_json', expires_in: 3.hours) do
      AclResource.acl_menu_resource_json
    end
  end

  def update_acl_resource_ids_cache
    Rails.cache.delete('acl_resource_ids')
    Rails.cache.fetch('acl_resource_ids', expires_in: 3.hours) do
      AclResource.acl_resource_ids
    end
  end


  def self.acl_resource_json
    resource_json = []
    models = []
    children = []
    acl_parent = []

    AclResource.where(is_menu_item: false).order(resource_model_name: :asc).each do |acl_resource|
      if !models.include? acl_resource.resource_model_alias_name
        if children.present? && children.size > 0
          acl_parent.children = children
          resource_json.push(acl_parent.marshal_dump)
          children = []
        end

        models << acl_resource.resource_model_alias_name

        #Parent Node
        acl_parent = OpenStruct.new
        acl_parent.id = acl_resource.id
        acl_parent.text = acl_resource.resource_model_alias_name
        acl_parent.checked = false
        acl_parent.hasChildren = true

        #First Child Node
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_alias_name
        acl_row.checked = false
        acl_row.hasChildren = false
        children.push(acl_row.marshal_dump)

      else
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_alias_name
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
    resource_json.to_json
  end

  def self.acl_menu_resource_json
    resource_json = []
    models = []
    children = []
    acl_parent = []

    AclResource.where(:is_menu_item => true).order(sort_order: :asc).each do |acl_resource|
      if !models.include? acl_resource.resource_model_alias_name
        if children.present? && children.size > 0
          acl_parent.children = children
          resource_json.push(acl_parent.marshal_dump)
          children = []
        end

        models << acl_resource.resource_model_alias_name

        #Parent Node
        acl_parent = OpenStruct.new
        acl_parent.id = acl_resource.id
        acl_parent.text = acl_resource.resource_model_alias_name
        acl_parent.checked = false
        acl_parent.hasChildren = true

        #First Child Node
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_alias_name
        acl_row.checked = false
        acl_row.hasChildren = false
        children.push(acl_row.marshal_dump)
      else
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_alias_name
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

    resource_json.to_json
  end

  def self.acl_resource_ids

    resource_ids = {}

    #All resources
    parsed_json = all_acl_resources
    parsed_json.map do |x|
      resource_ids[x[:text]] = {};
      x[:children].map {|y|
        resource_ids[x[:text]][y[:text]] = y[:id] if y[:text].present?}
    end

    resource_ids
  end

  def self.all_acl_resources
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

    resource_json
  end

end
