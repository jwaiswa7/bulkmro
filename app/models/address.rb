class Address < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasCountry

  belongs_to :state, class_name: 'AddressState', foreign_key: :address_state_id, required: false
  belongs_to :company

  validates_presence_of :name, :country_code, :city_name, :street1
  validates_presence_of :pincode, :state, :if => :domestic?
  validates_presence_of :state_name, :if => :international?

  def to_s
    [street1, street2, city_name, pincode, state.to_s, state_name, country_name].compact.join(', ')
  end
end