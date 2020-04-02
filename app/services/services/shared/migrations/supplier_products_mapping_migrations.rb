class Services::Shared::Migrations::SupplierProductsMappingMigrations < Services::Shared::BaseService
  def create_supplier_products
    InquiryProductSupplier.all.find_each(batch_size: 500) do |record|
      service = Services::Suppliers::CreateSupplierProduct.new(record)
      service.call
    end
  end
end