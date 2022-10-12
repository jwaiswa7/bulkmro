class CustomerRfq < ApplicationRecord
	include Mixins::CanBeStamped

  belongs_to :inquiry
  has_many_attached :files

	update_index('customer_rfqs#customer_rfq') {self}

  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }
end
