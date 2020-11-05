class Services::Shared::Migrations::TcsApplicableForServiceProduct < Services::Shared::BaseService
  def tcs_apply_for_service_product
    service = Services::Shared::Spreadsheets::CsvImporter.new('tcs_applicable_for_service1.csv', 'seed_files_3')
    service.loop(nil) do |x|
      Chewy.strategy(:bypass) do
        service_product = x.get_column('ItemNo')
        Product.where(sku: service_product, is_service: true).each do |product|
          product.update_attributes(tcs_applicable: false)
        end
      end
    end
  end
end