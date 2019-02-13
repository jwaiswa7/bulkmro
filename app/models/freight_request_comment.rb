

class FreightRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :freight_request

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
