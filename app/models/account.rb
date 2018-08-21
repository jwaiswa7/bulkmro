class Account < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  has_many :companies
  has_many :contacts
end
