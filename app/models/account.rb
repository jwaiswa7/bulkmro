class Account < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  has_many :companies
  has_many :contacts

  validates_presence_of :name
  validates_uniqueness_of :name
end
