class CustomerOrder < ApplicationRecord
  APPROVALS_CLASS = 'CustomerOrderApproval'
  REJECTIONS_CLASS = 'CustomerOrderRejection'
  COMMENTS_CLASS = 'CustomerOrderComment'
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasComments
  include Mixins::CanBeTotalled

  pg_search_scope :locate, against: [:id], associated_against: {company: [:name]}, using: {tsearch: {prefix: true}}

  belongs_to :contact
  belongs_to :company
  belongs_to :inquiry, required: false
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'
  has_many :items, dependent: :destroy, class_name: 'CustomerOrderRow'
  has_many :comments, dependent: :destroy, class_name: 'CustomerOrderComment'
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: 'Address', required: false
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: 'Address', required: false

  has_one_attached :customer_po_sheet

  enum payment_method: {
      'Bank Transfer': 10,
      'Online Payment': 20
  }

  enum order_type: {
    'Normal': 10,
    'Punchout': 20
  }

  def paid_online?
    self.online_payment.present?
  end

  def get_payment_method
    if self.payment_method.nil?
      self.update_attributes!(payment_method: 'Bank Transfer')
    end
    self.payment_method
  end

  def to_s
    super.gsub!('CustomerOrder', 'Order')
  end

  def total_quantities
    self.rows.pluck(:quantity).inject(0) {|sum, x| sum + x}
  end

  def status
    if self.approved?
      'Approved'
    elsif self.rejected?
      'Rejected'
    else
      'Pending Approval'
    end
  end

  def pending?
    self.not_approved? && self.not_rejected?
  end
end
