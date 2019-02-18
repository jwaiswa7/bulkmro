# frozen_string_literal: true

class Category < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasClosureTree
  include Mixins::CanBeSynced
  include Mixins::CanHaveTaxes
  include Mixins::CanBeActivated

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true, any_word: true } }

  has_many :category_suppliers
  has_many :suppliers, through: :category_suppliers

  validates_presence_of :name

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.is_service ||= false
  end

  def default_ancestors
    ['Root Catalog', 'Default Category']
  end

  def all_descendants
    children | children.map(&:descendants).flatten
  end

  def ancestors_to_s
    ancestry_path - default_ancestors
  end

  def autocomplete_to_s(level)
    case level
    when :grandparent
      name.to_s
    when :parent
      "- #{name}"
    when :child
      "-- #{name}"
    end
  end

  def self.root
    find_by_id(1)
  end

  def self.default
    first
  end
end
