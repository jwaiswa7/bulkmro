# frozen_string_literal: true

class PaymentRequestComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :payment_request

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
