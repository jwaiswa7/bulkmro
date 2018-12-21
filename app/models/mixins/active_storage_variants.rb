
module Mixins::ActiveStorageVariants
  extend ActiveSupport::Concern

  included do
    def image_transform(image)
      variation = Blob::variation("medium",true)
      ActiveStorage::Variant.new(image, variation).processed
    end
  end
end