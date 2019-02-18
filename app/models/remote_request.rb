# frozen_string_literal: true

class RemoteRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

  pg_search_scope :locate, against: [:url], associated_against: {}, using: { tsearch: { prefix: true } }
end
