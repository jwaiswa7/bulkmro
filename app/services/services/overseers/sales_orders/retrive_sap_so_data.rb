class Services::Overseers::SalesOrders::RetriveSapSoData < Services::Shared::BaseService
  def initialize(sales_order)
    @sales_order = sales_order
  end

  def call
    if sales_order.remote_uid.present?
      sap_so_data = ::Resources::Order.find(sales_order.remote_uid)
      if !sap_so_data['error'].present?
        sap_so_data['DocumentLines'].each_with_index do |documentline, index|
          sap_legacy_id = documentline['HSNEntry'] if documentline['HSNEntry'].present? || documentline['SACEntry']
          tax_code = TaxCode.where("remote_uid" => sap_legacy_id)
          sales_order.rows[index].sales_quote_row.update_attributes(:tax_code_id => tax_code[0].id)
        end
      end
    end
  end
  attr_accessor :sales_order
end