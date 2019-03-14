class InwardDispatchComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :inward_dispatch

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
