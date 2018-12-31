class Services::Overseers::SalesOrders::RetriveSapSoData < Services::Shared::BaseService
  def initialize(sales_order)
    @sales_order = sales_order
  end

  def call
    if sales_order.remote_uid.present?
      sap_so_data = ::Resources::Order.find(sales_order.remote_uid)
      sales_order_products_skus = sales_order.products.pluck('sku')
      if !sap_so_data['error'].present?
        sap_so_data['DocumentLines'].each do |documentline|
          if sales_order_products_skus.include?(documentline['ItemCode'])
            sap_legacy_id = documentline['HSNEntry'].present? ? documentline['HSNEntry'] : documentline['SACEntry']
            sales_order_row = sales_order.rows.joins(:sales_quote_row).joins(:product).where(products: {sku: documentline['ItemCode']}).first
            tax_code_id = TaxCode.where("remote_uid" => sap_legacy_id).first
            sales_order_row.sales_quote_row.update_attributes(:tax_code_id => tax_code_id.id)
          end
        end
      end
    end
  end
  attr_accessor :sales_order
end