class Category < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }
  has_closure_tree

  belongs_to :tax_code, required: false
  has_many :category_suppliers
  has_many :suppliers, :through => :category_suppliers

  validates_presence_of :name
  validates_presence_of :tax_code, :if => :child?

  def to_s
    ancestry_path.join(' > ')
  end
end