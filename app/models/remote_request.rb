class RemoteRequest < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry, required: false

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
