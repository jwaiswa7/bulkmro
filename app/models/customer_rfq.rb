class CustomerRfq < ApplicationRecord
	include Mixins::CanBeStamped

  belongs_to :inquiry
  
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: 'Address', required: false
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: 'Address', required: false

  has_many_attached :files
  
  has_many :email_messages, dependent: :destroy

	update_index('customer_rfqs#customer_rfq') {self}

  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }
end
