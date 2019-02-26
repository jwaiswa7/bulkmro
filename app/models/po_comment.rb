# frozen_string_literal: true

class PoComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :purchase_order

  def author
    created_by
  end

  def author_role
    author.role.titleize
  end
end
