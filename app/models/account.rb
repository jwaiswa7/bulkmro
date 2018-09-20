class Account < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :companies
  has_many :contacts
end
