class PaymentOption < ApplicationRecord
  include Mixins::HasUniqueName

  has_many :companies
  has_many :inquiries
end
