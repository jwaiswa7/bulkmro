class Blob
  class << self
    IMAGE_SIZES = { tiny: 50, small: 250, medium: 400, xlarge: 2400 }
    WATERMARK_PATH = Rails.root.join('app', 'assets', 'images', 'watermark.png')

    def variation(style,watermark=false)
      puts "variation block"
      puts combine_options(style,watermark)
      ActiveStorage::Variation.new(combine_options: combine_options(style,watermark))
    end

    def combine_options(style,watermark)
      style = style.to_sym
      size = IMAGE_SIZES[style] || IMAGE_SIZES[:small]
      if watermark
        { resize: "#{size}X#{size}", gravity: 'Center', draw: "image SrcOver 0,0,#{size},#{size} '#{WATERMARK_PATH.to_s}'" }
      else
        { resize: "#{size}X#{size}" }
      end
    end
  end
end