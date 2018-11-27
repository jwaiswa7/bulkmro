class Category < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasClosureTree
  include Mixins::CanBeSynced
  include Mixins::CanHaveTaxes
  include Mixins::CanBeActivated

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  has_many :category_suppliers
  has_many :suppliers, :through => :category_suppliers

  validates_presence_of :name

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.is_service ||= false
  end

  def default_ancestors
    ["Root Catalog", "Default Category"]
  end

  def ancestors_to_s
    self.ancestry_path - default_ancestors
  end

  def self.default
    first
  end
end