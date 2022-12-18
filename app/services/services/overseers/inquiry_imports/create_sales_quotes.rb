class Services::Overseers::InquiryImports::CreateSalesQuotes < Services::Shared::BaseService
    def initialize(inquiry, import)
      @inquiry = inquiry
      @import = import
    end
  
    def call
        last_sale_quote = @inquiry.sales_quotes.last.try(:id)
        sales_quote = SalesQuote.new(inquiry_id: @inquiry.id , parent_id: last_sale_quote)
    
        @import.rows.each do |row|
    
          product = Product.active.where('lower(sku) = ? ', row.sku.downcase).try(:first)
          inquiry_product = @inquiry.inquiry_products.where(product: product).try(:first)
          supplier = Company.where(remote_uid: row.metadata['vendor_code'].to_s).try(:first)
          inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(supplier_id: supplier.id)&.first
    
          if product.present? && inquiry_product.present? && supplier.present? && inquiry_product_supplier.present?
    
            max_lead_time_days = row.metadata['max_lead_time_days'].to_i
            min_lead_time_days = row.metadata['mim_lead_time_days'].to_i
            lead_time =  LeadTimeOption.where( min_days: min_lead_time_days, max_days: max_lead_time_days)&.last || LeadTimeOption.where( min_days: 14, max_days: 21)&.last
            unit_cost_price = row.metadata['unit_buying_price'].to_i
            unit_selling_price = row.metadata['unit_selling_price'].to_i
            gst = row.metadata['gst_percentage'].to_f
            tax_code = row.metadata['tax_code'].to_s
            
            margin_percentage = ( ( (unit_selling_price - unit_cost_price).to_f / unit_selling_price.to_f ) * 100.00 ).round(2)
            sales_quote.rows.build(
              inquiry_product_supplier_id: inquiry_product_supplier.id ,
              remote_uid: inquiry_product.sr_no ,
              tax_code_id: TaxCode.where(code: tax_code)&.last&.id  , 
              tax_rate_id: TaxRate.where(tax_percentage: gst)&.last&.id , 
              lead_time_option_id: lead_time.id , 
              quantity: inquiry_product.quantity ,
              measurement_unit_id: product.measurement_unit_id ,
              margin_percentage: margin_percentage ,
              unit_selling_price: unit_selling_price 
            )
          end
        end
    
        #sale quotes process
        sales_quote.rows.each do |row|
        row.converted_unit_selling_price = row.calculated_converted_unit_selling_price
        end
        if !@import.rows.failed.any?
          sales_quote.update_attributes!(sent_at: Time.now)
        end
    
    
        if sales_quote.sent_at.present?
          sales_quote.save_and_sync
          remote_uid = SalesQuote.maximum('remote_uid') + 1
          sales_quote.update_attributes(remote_uid: remote_uid)
          sales_quote.inquiry.update_attributes(quotation_uid: remote_uid)
        else
          sales_quote.save
        end
    
    end
  
    attr_accessor :inquiry, :import
  end
  