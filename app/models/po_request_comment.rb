# frozen_string_literal: true

class PoRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :po_request

  validates_presence_of :message

  def author
    created_by
  end

  def author_role
    author.role.titleize
  end
end
