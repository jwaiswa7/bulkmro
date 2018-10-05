class Category < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasClosureTree

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }


  belongs_to :tax_code, required: false
  has_many :category_suppliers
  has_many :suppliers, :through => :category_suppliers



  validates_presence_of :name
  #validates_presence_of :tax_code, :if => :child?
  # validates_presence_of :remote_uid
  #
  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.is_service ||= false
  end

  def self.default
    first
  end
end