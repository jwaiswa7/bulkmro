class Blob
  class << self
    IMAGE_SIZES = { tiny: 50, small: 250, medium: 400, xlarge: 2400 }
    WATERMARK_PATH = Rails.root.join('app', 'assets', 'images', 'watermark.png')

    def variation(size,watermark=true)
      ActiveStorage::Variation.new(combine_options: combine_options(size,watermark))
    end

    def combine_options(size="small",watermark)
      size = IMAGE_SIZES[size.to_sym]
      ratio = "#{size}X#{size}"
      if watermark
        { resize: "#{ratio}^", extent: "#{ratio}", quality: "90", gravity: 'Center', draw: "image SrcOver 0,0,#{size},#{size} '#{WATERMARK_PATH.to_s}'" }
      else
        { resize: "#{ratio}", quality: "90", extent: "#{ratio}" }
      end
    end
  end
end