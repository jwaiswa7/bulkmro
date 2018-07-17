class Account < ApplicationRecord
  include Mixins::CanBeStamped
  
  has_many :companies
  has_many :contacts

  validates_presence_of :name
  validates_uniqueness_of :name
end
