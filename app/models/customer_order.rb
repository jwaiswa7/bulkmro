class CustomerOrder < ApplicationRecord
  belongs_to :contact
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'
  belongs_to :billing_address, -> (record) {where(company_id: record.id)}, class_name: 'Address', foreign_key: :billing_address_id, required: false
  belongs_to :shipping_address, -> (record) {where(company_id: record.id)}, class_name: 'Address', foreign_key: :shipping_address_id, required: false

  def to_s
    super.gsub!('CustomerOrder', 'Order')
  end
end
