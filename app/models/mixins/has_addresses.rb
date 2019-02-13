

module Mixins::HasAddresses
  extend ActiveSupport::Concern

  included do
    belongs_to :billing_address, -> (object) { where(company: object.company) }, class_name: 'Address', foreign_key: 'billing_address_id'
    belongs_to :shipping_address, -> (object) { where(company: object.company) }, class_name: 'Address', foreign_key: 'shipping_address_id'
  end
end
