class Services::Overseers::SalesOrders::FetchOrderData < Services::Shared::BaseService
  def initialize(sales_order)
    @sales_order = sales_order
  end

  def call
    if sales_order.remote_uid.present?
      sap_so_data = ::Resources::Order.find(sales_order.remote_uid)
      sales_order_products_skus = sales_order.products.pluck('sku')

      sap_so_data['DocumentLines'].each do |item|
        if sales_order_products_skus.include?(item['ItemCode'])
          remote_uid = item['HSNEntry'].present? ? item['HSNEntry'] : item['SACEntry']
          tax_code_id = TaxCode.where('remote_uid' => remote_uid).first
          tax_rate_id = item['TaxCode'].match(/([+-]?(?:0|[1-9]\d*)(?:\.(?:\d*[1-9]|0))?)/) ? TaxRate.where('tax_percentage' => item['TaxCode'].match(/([+-]?(?:0|[1-9]\d*)(?:\.(?:\d*[1-9]|0))?)/)[0].to_f).first : nil
          
          sales_order_row = sales_order.rows.joins(:sales_quote_row).joins(:product).where(products: { sku: item['ItemCode'] }).first
          sales_order_row.sales_quote_row.update_attributes(tax_code_id: tax_code_id.id) if tax_code_id.present?
          sales_order_row.sales_quote_row.update_attributes(tax_rate_id: tax_rate_id.id) if tax_rate_id.present?
        end
      end if sap_so_data['error'].blank?
    end
  end

  attr_accessor :sales_order
end



# NetTaxAmount, TaxTotal, TaxAmount