class PaymentOption < ApplicationRecord
  include Mixins::HasUniqueName

  has_many :companies
  has_many :inquiries

  def self.default
    first
  end
end
