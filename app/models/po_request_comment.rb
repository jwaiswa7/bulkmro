class PoRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :po_request

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
