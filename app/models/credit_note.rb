class CreditNote < ApplicationRecord
  include Mixins::CanBeSynced
  update_index('credit_notes#credit_note') { self }

  belongs_to :sales_invoice
  scope :with_includes, -> { includes(:sales_invoice) }
end
