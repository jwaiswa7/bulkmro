# frozen_string_literal: true

module Mixins::IsARequest
  extend ActiveSupport::Concern

  included do
    has_paper_trail on: []
    belongs_to :subject, polymorphic: true, required: false

    enum status: {
      success: 10,
      failed: 20,
      pending: 30
    }

    enum method: {
      get: 10,
      post: 20,
      patch: 30,
      callback: 40
    }


  end
end
