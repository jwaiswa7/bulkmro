class ProductComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :product
  has_one :approval, class_name: 'ProductApproval'
  has_one :rejection, class_name: 'ProductRejection'

  attr_accessor :merge_product

  validates_presence_of :message
end
