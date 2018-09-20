class Brand < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  has_many :brand_suppliers
  has_many :suppliers, :through => :brand_suppliers
  has_many :products

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end
end