class ArInvoiceComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :ar_invoice

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
