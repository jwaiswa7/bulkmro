class CustomerRfq < ApplicationRecord
	include Mixins::CanBeStamped

  belongs_to :inquiry
  
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: 'Address', required: false
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: 'Address', required: false

  has_many_attached :files
  
  has_many :email_messages, dependent: :destroy
  has_many :inquiry_products, through: :inquiry
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda {|attributes| attributes['product_id'].blank? && attributes['id'].blank?}, allow_destroy: true


	update_index('customer_rfqs#customer_rfq') {self}

  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }
  
end
