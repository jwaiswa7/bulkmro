class Services::Overseers::InquiryImports::CreateFailedSkus < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    excel_import.inquiry_products.each do |inquiry_product|
      if inquiry_product.marked_for_destruction?

      else
        successful_sku_metadata, failed_skus_metadata = excel_import.failed_skus_metadata.partition { |failed_sku_metadata| failed_sku_metadata['sku'] == inquiry_product.failed_sku }
        excel_import.successful_skus_metadata << successful_sku_metadata
        excel_import.failed_skus_metadata = failed_skus_metadata
      end
    end

    # if excel_import.save
    #   excel_import.update_attributes(:failed_skus => [], :failed_skus_metadata => {})
    # end

    excel_import.save
  end

  def notify

  end

  attr_accessor :inquiry, :excel_import
end