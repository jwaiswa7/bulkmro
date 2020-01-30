class Services::Suppliers::BuildFromInquiryProductSupplier < Services::Shared::BaseService
  def initialize(rfq, params)
    @rfq = rfq
    @params = params
  end

  def call
    rfq.inquiry_product_suppliers.each do |inquiry_product_supplier|
      if inquiry_product_supplier.supplier_rfq_revisions.present?
        inquiry_product_supplier.supplier_rfq_revisions.each do |rfq_revision|
          params["inquiry_product_suppliers_attributes"].each do |key, value|
            if !(value.to_hash == JSON.parse(rfq_revision.rfq_data))
              json_params = value.to_json
              rfq_revision = inquiry_product_supplier.supplier_rfq_revisions.new(rfq_data: json_params)
              rfq_revision.save
            end
            next
          end
          next
        end
      else
        params["inquiry_product_suppliers_attributes"].each do |key, value|
          json_params = value.to_json
          rfq_revision = inquiry_product_supplier.supplier_rfq_revisions.new(rfq_data: json_params)
          rfq_revision.save
        end
      end
    end  
  end

  attr_reader :rfq, :params
end
