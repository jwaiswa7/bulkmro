# frozen_string_literal: true

class Services::Customers::CustomerProducts::FlushUnavailableImages < Services::Shared::BaseService
  def call
    CustomerProduct.all.each do |customer_product|
      if customer_product.best_images.present?
        customer_product.best_images.each do |image|
          if image.key.blank?
            image.destroy
          else
            if ActiveStorage::Blob.service.exist?(image.key)
              path = "#{Dir.tmpdir}/#{image.key}#{image.filename}"
              File.open(path, 'wb') do |file|
                file.write(image.download)
              end

              if !File.exist?(path)
                image.destroy
              end
            else
              image.destroy
            end
          end
        end
      end
    end
  end
end
