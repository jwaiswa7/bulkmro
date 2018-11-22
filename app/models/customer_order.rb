class CustomerOrder < ApplicationRecord
  belongs_to :contact
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'
  belongs_to :default_billing_address, -> (record) {where(company_id: record.id)}, class_name: 'Address', foreign_key: :default_billing_address_id, required: false
  belongs_to :default_shipping_address, -> (record) {where(company_id: record.id)}, class_name: 'Address', foreign_key: :default_shipping_address_id, required: false
end
