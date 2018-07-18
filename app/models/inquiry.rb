class Inquiry < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :contact
  belongs_to :company

  belongs_to :billing_address, class_name: 'Address', foreign_key: 'billing_address_id'
  belongs_to :shipping_address, class_name: 'Address', foreign_key: 'shipping_address_id'

  has_many :quotes
  has_many :rfqs

end
