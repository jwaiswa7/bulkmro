# frozen_string_literal: true

class Brand < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::CanBeActivated

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  has_many :brand_suppliers
  has_many :suppliers, through: :brand_suppliers
  has_many :products

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end

  def self.legacy
    find_by_name('Legacy Brand')
  end

  def self.default
    find_by(name: 'BULK MRO APPROVED')
  end

end
