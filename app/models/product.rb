class Product < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:sku, :name], :associated_against => { brand: [:name] }, :using => { :tsearch => {:prefix => true} }

  belongs_to :brand
  belongs_to :category
  has_many :product_suppliers

  has_many :p_suppliers, :through => :product_suppliers, class_name: 'Company', source: :supplier
  has_many :b_suppliers, :through => :brand, class_name: 'Company', source: :suppliers

  def c_suppliers
    Company.joins(:category_suppliers).where('category_id IN (?)', self.category.self_and_descendants.map(&:id))
  end

  def suppliers
    Company.where('id in (?)', p_suppliers.pluck(:id) + c_suppliers.pluck(:id) + b_suppliers.pluck(:id)).uniq
  end

  validates_presence_of :name, :sku
  validates_uniqueness_of :sku

  def to_s
    "#{brand.name} > #{name} (#{sku})"
  end
end
