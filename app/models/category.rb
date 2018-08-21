class Category < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }
  has_closure_tree

  has_many :category_suppliers
  has_many :suppliers, :through => :category_suppliers

  validates_presence_of :name

  def to_s
    ancestry_path.join(' > ')
  end
end