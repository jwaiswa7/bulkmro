class Account < ApplicationRecord
  has_many :companies
  accepts_nested_attributes_for :companies
  has_many :contacts
  accepts_nested_attributes_for :contacts

  validates_presence_of :name
end
