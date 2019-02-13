

class PoComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :purchase_order

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
