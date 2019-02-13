class InquiryComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :contact, required: false
  belongs_to :sales_order, required: false
  has_one :approval, class_name: 'SalesOrderApproval', dependent: :destroy
  has_one :rejection, class_name: 'SalesOrderRejection', dependent: :destroy

  scope :internal_comments, -> { where(show_to_customer: [false, nil]) }
  scope :customer_comments, -> { where(show_to_customer: true) }

  after_create :update_inquiry, if: :persisted?

  def update_inquiry
    self.inquiry.touch(:updated_at)
  end

  def author
    self.contact || self.created_by
  end

  def author_role
    author.role.titleize
  end
end
