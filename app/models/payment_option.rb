class PaymentOption < ApplicationRecord
  has_many :companies
  has_many :inquiries
end
