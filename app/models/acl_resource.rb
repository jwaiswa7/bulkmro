class AclResource < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, against: [:resource_model_name, :resource_action_name], using: {tsearch: {prefix: true}}

  after_save :update_acl_resource_cache

  def update_acl_resource_cache
    Rails.cache.delete('acl_resource_json')

    Rails.cache.fetch('acl_resource_json', expires_in: 3.hours) do
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
      end

      resource_json.to_json
    end
  end
end
