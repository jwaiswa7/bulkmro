# frozen_string_literal: true

class PaymentOption < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::HasUniqueName

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  has_many :companies
  has_many :inquiries
  has_many :purchase_orders

  def self.default
    first
  end
end
