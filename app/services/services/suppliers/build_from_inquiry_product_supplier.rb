class Services::Suppliers::BuildFromInquiryProductSupplier < Services::Shared::BaseService
  def initialize(rfq, params)
    @rfq = rfq
    @params = params
  end

  def call
    rfq.inquiry_product_suppliers.each do |inquiry_product_supplier|
      if inquiry_product_supplier.supplier_rfq_revisions.present?
        rfq_revision = inquiry_product_supplier.supplier_rfq_revisions.last
        params["inquiry_product_suppliers_attributes"].each do |key, value|
          if compare(value.to_hash, JSON.parse(rfq_revision.rfq_data)) && (JSON.parse(rfq_revision.rfq_data)["id"] == value.to_hash["id"])
            json_params = value.to_json
            rfq_revision = inquiry_product_supplier.supplier_rfq_revisions.new(rfq_data: json_params)
            rfq_revision.save
          end
        end
      else
        params["inquiry_product_suppliers_attributes"].each do |key, value|
          if value["id"].to_i == inquiry_product_supplier.id
            json_params = value.to_json
            rfq_revision = inquiry_product_supplier.supplier_rfq_revisions.new(rfq_data: json_params)
            rfq_revision.save
          end
        end
      end
    end  
  end

  private

  def compare(param1, param2)
    arr1 = param1.slice("last_unit_price", "unit_cost_price", "gst", "unit_freight", "final_unit_price", "total_price").values.map {|x| x[/\d+/]}
    arr2 = param2.slice("last_unit_price", "unit_cost_price", "gst", "unit_freight", "final_unit_price", "total_price").values.map {|x| x[/\d+/]}

    if arr1 != arr2
      true
    else
      false
    end
  end

  attr_reader :rfq, :params
end
