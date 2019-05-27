class AclResource < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, against: [:resource_model_name, :resource_action_name], using: {tsearch: {prefix: true}}
end
