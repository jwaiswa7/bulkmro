

class Cart < ApplicationRecord
  include Mixins::CanBeTotalled

  belongs_to :contact
  belongs_to :company, required: false
  has_many :items, class_name: "CartItem", dependent: :destroy
  accepts_nested_attributes_for :items
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: "Address", required: false
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: "Address", required: false

  after_initialize :set_global_defaults

  enum payment_method: {
      'Bank Transfer': 10,
      'Online Payment': 20
  }

  def set_global_defaults
    if self.company.present?
      self.billing_address ||= company.addresses.first
      self.shipping_address ||= company.addresses.first
    end
  end
end
