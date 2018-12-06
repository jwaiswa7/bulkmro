class PaymentOption < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::HasUniqueName

  pg_search_scope :locate, :against => [:name], :associated_against => {}, :using => {:tsearch => {:prefix => true}}

  has_many :companies
  has_many :inquiries

  def self.default
    first
  end
end
