class PaymentOption < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::HasUniqueName

  default_scope { where(active: true) }
  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  has_many :companies
  has_many :inquiries
  has_many :purchase_orders
  has_many :po_requests

  def self.default
    first
  end
end
