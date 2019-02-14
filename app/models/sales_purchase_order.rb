class SalesPurchaseOrder < ApplicationRecord
  include Mixins::CanBeSynced

  belongs_to :inquiry

  def self.syncable_identifiers
    [:po_number]
  end
end
