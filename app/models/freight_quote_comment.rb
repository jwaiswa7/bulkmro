# frozen_string_literal: true

class FreightQuoteComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :freight_quote

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end
end
