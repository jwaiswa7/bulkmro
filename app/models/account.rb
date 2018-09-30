class Account < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  # validates_presence_of :alias
  # validates_uniqueness_of :alias
  # validates_length_of :alias, :maximum => 20

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :companies
  has_many :contacts
  has_many :inquiries, :through => :companies
  has_many :addresses, :through => :companies

  def self.legacy
    find_by_name('Legacy Account')
  end

  def self.trade
    find_by_name('Trade')
  end

  def self.non_trade
    find_by_name('Non-Trade')
  end
end
