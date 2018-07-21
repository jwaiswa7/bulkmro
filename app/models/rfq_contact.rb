class RfqContact < ApplicationRecord
  belongs_to :rfq
  belongs_to :contact

  validates_uniqueness_of :contact, scope: :rfq
end
