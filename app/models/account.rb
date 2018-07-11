class Account < ApplicationRecord
  has_many :companies
  has_many :contacts
end
