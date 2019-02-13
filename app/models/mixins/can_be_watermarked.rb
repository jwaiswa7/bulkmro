

module Mixins::CanBeWatermarked
  extend ActiveSupport::Concern

  included do
    IMAGE_SIZES = { tiny: 40, small: 250, medium: 400, xlarge: 2400 }
    WATERMARK_PATH = Rails.root.join("app", "assets", "images", "watermark.png")

    after_save :create_watermarked_variation

    def create_watermarked_variation
      if self.best_image.present?
        tiny_best_image
        medium_best_image
      end
    end

    def watermarked_variation(image, image_size)
      size = IMAGE_SIZES[image_size.to_sym]
      ratio = "#{size}X#{size}"

      variation = ActiveStorage::Variation.new(
        combine_options: {
            resize: "#{ratio}^",
            extent: "#{ratio}",
            quality: "90",
            gravity: "Center",
            draw: "image SrcOver 0,0,#{size},#{size} '#{WATERMARK_PATH.to_s}'"
        }
      )
      begin
        if image.present?
          ActiveStorage::Variant.new(image, variation).processed
        else
          "/assets/coming_soon.png"
        end
      rescue Errno::ENOENT => e
        nil
      end
    end

    def tiny_best_image
      watermarked_variation(self.best_image, "tiny")
    end

    def medium_best_image
      watermarked_variation(self.best_image, "medium")
    end
  end
end
