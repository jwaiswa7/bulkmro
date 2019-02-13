class ProductComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :product
  has_one :approval, class_name: 'ProductApproval'
  has_one :rejection, class_name: 'ProductRejection'

  attr_accessor :merge_with_product_id

  validates_presence_of :message

  def merged?
    (self.merged_product_name || self.merged_product_sku || self.merged_product_metadata).present?
  end
end
