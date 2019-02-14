# frozen_string_literal: true

class Warehouse < ApplicationRecord
  include Mixins::HasVisibility
  include Mixins::CanBeActivated

  default_scope { order(name: :asc) }
  pg_search_scope :locate, against: [:name], associated_against: { address: [:name, :country_code, :street1, :street2, :state_name, :city_name, :pincode] }, using: { tsearch: { prefix: true } }

  belongs_to :address, required: true
  accepts_nested_attributes_for :address
  has_many :bill_from_inquiries, inverse_of: :bill_from, foreign_key: :bill_from_id, class_name: 'Inquiry', dependent: :nullify
  has_many :ship_from_inquiries, inverse_of: :ship_from, foreign_key: :ship_from_id, class_name: 'Inquiry', dependent: :nullify
  has_many :product_stocks, class_name: 'WarehouseProductStock', inverse_of: :warehouse, dependent: :destroy

  validates_presence_of :address
  validates_presence_of :name

  #
  scope :with_includes, -> { includes(:address) }

  def self.default
    find_by_name('Mumbai - Lower Parel')
  end
end
