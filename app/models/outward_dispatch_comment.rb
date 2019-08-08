class OutwardDispatchComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :outward_dispatch

  validates_presence_of :message

  def author
    created_by
  end

  def author_role
    author.role.titleize
  end
end