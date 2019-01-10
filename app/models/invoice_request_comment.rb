
class InvoiceRequestComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :invoice_request

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
