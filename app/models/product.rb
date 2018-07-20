class Product < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:sku, :name], :associated_against => { brand: [:name] }, :using => {
      :tsearch => {:prefix => true}
  }

  belongs_to :brand
  belongs_to :category
  has_many :product_suppliers

  has_many :b_suppliers, :through => :brand, class_name: 'Company', source: :suppliers
  has_many :p_suppliers, :through => :product_suppliers, class_name: 'Company', source: :supplier

  def suppliers
    Company.where('id in (?)', b_suppliers.pluck(:id) + p_suppliers.pluck(:id)).uniq
  end

  validates_presence_of :name, :sku
  validates_uniqueness_of :sku

  def to_s
    "#{brand.name} > #{name} (#{sku})"
  end
end
