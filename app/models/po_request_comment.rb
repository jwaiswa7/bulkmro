# frozen_string_literal: true

class PoRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :po_request

  def author
    created_by
  end

  def author_role
    author.role.titleize
  end
end
