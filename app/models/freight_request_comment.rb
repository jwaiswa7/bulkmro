# frozen_string_literal: true

class FreightRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :freight_request

  def author
    created_by
  end

  def author_role
    author.role.titleize
  end
end
