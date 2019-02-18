# frozen_string_literal: true

class InvoiceRequestComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :invoice_request

  def author
    created_by
  end

  def author_role
    author.role.titleize
  end
end
