class Category < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasClosureTree
  include Mixins::CanBeSynced
  include Mixins::CanHaveTaxes
  include Mixins::CanBeActivated

  pg_search_scope :locate, :against => [:name], :associated_against => {}, :using => {:tsearch => {:prefix => true, :any_word => true}}

  has_many :category_suppliers
  has_many :suppliers, :through => :category_suppliers

  validates_presence_of :name

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.is_service ||= false
  end

  def self.default_ancestors
    ["Root Catalog", "Default Category"]
  end

  def all_descendants
    self.children | self.children.map(&:descendants).flatten
  end

  def ancestors_to_s
    self.ancestry_path - Category.default_ancestors
  end

  def autocomplete_to_s(level)
    case level
    when :grandparent
      "#{self.name}"
    when :parent
      "- #{self.name}"
    when :child
      "-- #{self.name}"
    else
    end
  end

  def self.root
    self.find_by_id(1)
  end

  def self.default
    first
  end
end