class CreateTaskComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :task

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end

