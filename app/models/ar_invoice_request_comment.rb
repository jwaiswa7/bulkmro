class ArInvoiceRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :ar_invoice_request

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
