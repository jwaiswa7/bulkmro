class CustomerOrderComment < ApplicationRecord
  include Mixins::Customers::CanBeStamped

  belongs_to :customer_order
  belongs_to :contact

  has_one :approval, class_name: 'CustomerOrderApproval', dependent: :destroy
  has_one :rejection, class_name: 'CustomerOrderRejection', dependent: :destroy

  scope :internal_comments, -> {where(:show_to_customer => [false, nil])}
  scope :customer_comments, -> {where(:show_to_customer => true)}

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
