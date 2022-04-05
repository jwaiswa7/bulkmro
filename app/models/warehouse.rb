class Warehouse < ApplicationRecord
  include Mixins::HasVisibility
  include Mixins::CanBeActivated

  default_scope { order(name: :asc) }
  pg_search_scope :locate, against: [:name, :series_code], associated_against: { address: [:name, :country_code, :street1, :street2, :state_name, :city_name, :pincode] }, using: { tsearch: { prefix: true } }

  belongs_to :address, required: true
  accepts_nested_attributes_for :address
  has_many :bill_from_inquiries, inverse_of: :bill_from, foreign_key: :bill_from_id, class_name: 'Inquiry', dependent: :nullify
  has_many :ship_from_inquiries, inverse_of: :ship_from, foreign_key: :ship_from_id, class_name: 'Inquiry', dependent: :nullify
  has_many :bill_to_po_request, inverse_of: :bill_to, foreign_key: :bill_to_id, class_name: 'PoRequest', dependent: :nullify
  has_many :ship_to_po_request, inverse_of: :ship_to, foreign_key: :ship_to_id, class_name: 'PoRequest', dependent: :nullify
  has_one :delivery_challan, as: :supplier_bill_from, dependent: :nullify
  has_one :delivery_challan, as: :supplier_ship_from, dependent: :nullify
  has_many :product_stocks, class_name: 'WarehouseProductStock', inverse_of: :warehouse, dependent: :destroy

  validates_presence_of :address
  validates_presence_of :name

  scope :with_includes, -> { includes(:address) }


  enum series_code: {
      'LWP': 1,
      'ALT': 2,
      'PUN': 3,
      'BOP': 4,
      'MAN': 5,
      'OKH': 6,
      'JNK': 7,
      'CHE': 8,
      'HYD': 9,
      'BAN': 10,
      'HP': 11,
      'LPN': 12,
      'BHW': 13,
      'AMB': 14,
      'HR': 15,
      'SHT': 16,
      'AMD': 17,
      'MUM': 18,
      'GJ': 19,
      'DL': 20, 
      'CH': 21,
      'KA': 22
  }


  def self.default
    find_by_name('Mumbai - Lower Parel')
  end
end
