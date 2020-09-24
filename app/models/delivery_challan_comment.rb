class DeliveryChallanComment < ApplicationRecord
	include Mixins::CanBeStamped
  belongs_to :delivery_challan

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end