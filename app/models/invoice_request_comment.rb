class InvoiceRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :invoice_request
end
