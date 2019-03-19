class Services::Shared::Migrations::AddCompanyToPurchaseOrder < Services::Shared::Migrations::Migrations
  def call
    PurchaseOrder.all.each do |purchase_order|
      purchase_order.update_attributes(company: purchase_order&.get_supplier)
      purchase_order.rows.each do |purchase_order_row|
        purchase_order_row.update_attributes(product: purchase_order_row&.get_product)
      end
    end
    Rake::Task['chewy:reset'].invoke('companies')
  end
end
