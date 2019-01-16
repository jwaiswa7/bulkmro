module Mixins::HasImages
  extend ActiveSupport::Concern

  included do
    has_many_attached :images
    scope :with_attachments, -> {joins(:images_attachments)}
  end
end