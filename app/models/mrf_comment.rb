class MrfComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :material_readiness_followup

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
