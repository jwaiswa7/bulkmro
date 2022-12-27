class Services::Overseers::InquiryImports::CreateRfqs < Services::Shared::BaseService
    def initialize(inquiry, import)
      @inquiry = inquiry
      @import = import
    end
  
    def call
        @import.rows.each do |row|
            if row.sku.present?
              product = Product.active.where('lower(sku) = ? ', row.sku.downcase).try(:first)
              inquiry_product = @inquiry.inquiry_products.where(product: product).try(:first)
              supplier = Company.where(remote_uid: row.metadata['vendor_code'].to_s).try(:first)
      
              if product.present? && inquiry_product.present? && supplier.present? && product.inquiry_product_suppliers.present?
      
                max_lead_time_days = row.metadata['max_lead_time_weeks'].to_i * 7
                lead_time = Time.now + max_lead_time_days.days
                unit_cost_price = row.metadata['unit_buying_price'].to_i
                gst = row.metadata['gst_percentage'].to_f
                freight = row.metadata['freight'].to_i
                final_unit_price = unit_cost_price.to_f + ( (unit_cost_price.to_f / 100.00 ) * gst ) + freight.to_f
                inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(supplier_id: supplier.id).first_or_create
                inquiry_product_supplier.update_attributes(
                  unit_cost_price: unit_cost_price,
                  last_unit_price: unit_cost_price,
                  lead_time: Date.parse(lead_time.to_s),
                  gst:  gst.to_s,
                  unit_freight: freight,
                  final_unit_price: final_unit_price ,
                  total_price: inquiry_product.quantity * final_unit_price
                )
      
                if inquiry_product_supplier.save!
                  rfq_number = (SupplierRfq.last.rfq_number.to_i + 1) if SupplierRfq.count > 0 && SupplierRfq.first.rfq_number.present?
                  supplier_rfq = SupplierRfq.where(inquiry_id: @inquiry.id, supplier_id: inquiry_product_supplier.supplier.id).first_or_create
                  supplier_rfq.update_attributes(rfq_number: rfq_number)
                  inquiry_product_supplier.update(supplier_rfq: supplier_rfq)
      
                end
                row.update_attributes(inquiry_product: inquiry_product)
                row.save!
              end
            end
        end
    end
  
    attr_accessor :inquiry, :import
  end
  