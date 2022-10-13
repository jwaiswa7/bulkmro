class Services::Customers::CustomerOrders::CreateQuoteAndOrder < Services::Shared::BaseService

    def initialize(customer_order)
      @customer_order = customer_order
    end
  
    def call
      
        inquiry = Inquiry.where(company_id: @customer_order.company_id , customer_po_number: @customer_order.po_reference).last
        inquiry.billing_address_id = @customer_order.billing_address_id
        inquiry.shipping_address_id = @customer_order.shipping_address_id
        inquiry.skip_dates_validations = true
        inquiry.save!

        last_sale_quote = inquiry.sales_quotes.last.try(:id)
        sales_quote = SalesQuote.new(inquiry_id: inquiry.id , sent_at: Time.now , parent_id: last_sale_quote)

        @customer_order.rows.each do |row|
          #calculate cost price and supplier

          cost_price = row.product.inquiry_product_suppliers.where("unit_cost_price >  0.0").minimum('unit_cost_price') if row.product.inquiry_product_suppliers.present?
          if cost_price && cost_price <= row.customer_product.customer_price
            margin_percentage = (( (row.customer_product.customer_price - cost_price) / row.customer_product.customer_price ) * 100).round(2) 
          else
            margin_percentage = 0
            cost_price = row.customer_product.customer_price
          end

          supplier_id = Company.where(name: "Bulk MRO Industrial Supply Pvt. Ltd." , account_id: 1).last.id 

          #create inquiry Product and inquiry_product_supplier

          if inquiry.product_ids.include?(row.product_id.to_i)
            inquiry_product = inquiry.inquiry_products.where(product_id: row.product_id.to_i).last
            inquiry_product.update( quantity: row.quantity.to_i)
          else
            inquiry.inquiry_products.build(sr_no: inquiry.inquiry_products.present? ? ( inquiry.inquiry_products.last.sr_no + 1 ) : 1 , product_id: row.product_id.to_i , quantity: row.quantity.to_i)
            inquiry.skip_dates_validations = true
            inquiry.save!
            inquiry_product =  inquiry.inquiry_products.last
          end

          if inquiry_product.inquiry_product_suppliers.where(supplier_id: supplier_id).count > 0
            inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(supplier_id: supplier_id).last
            inquiry_product_supplier.update(unit_cost_price: cost_price, lead_time: Date.today + 7 ,gst: row.tax_rate.tax_percentage)
          else
            inquiry_product.inquiry_product_suppliers.build(supplier_id: supplier_id,unit_cost_price: cost_price, lead_time: Date.today + 7 ,gst: row.tax_rate.tax_percentage)
            inquiry_product.save!
            inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.last
          end
          sales_quote.rows.build(inquiry_product_supplier_id: inquiry_product_supplier.id , remote_uid: inquiry_product.sr_no , tax_code_id: row.tax_code_id , tax_rate_id: row.tax_rate_id , lead_time_option_id: LeadTimeOption.where( min_days: 7, max_days: 7).last.id , quantity: row.quantity ,measurement_unit_id: row.product.measurement_unit_id , margin_percentage: margin_percentage , unit_selling_price: row.customer_product.customer_price )

        end

        #sale quotes process
        sales_quote.rows.each do |row|
        row.converted_unit_selling_price = row.calculated_converted_unit_selling_price
        end

        sales_orders_total = @customer_order.company.company_transactions_amounts.where(financial_year: Company.current_financial_year).last.total_amount
        sales_quote.metadata = { company_total: sales_orders_total }
        sales_quote.save!
        sales_quote.save_and_sync

        # remote_uid = SalesQuote.maximum('remote_uid') + 1
        # sales_quote.update_attributes(remote_uid: remote_uid)
        # sales_quote.inquiry.update_attributes(quotation_uid: remote_uid)

        # sales order

        sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(sales_quote, nil).call
        sales_order.legacy_metadata = { company_total: sales_orders_total }
        sales_order.save!

        # sales_order.update_attributes(sent_at: Time.now)

        date = Date.today
        year = date.year
        year = year - 1 if date.month < 4
        series_name = sales_order.sales_quote.bill_from.series_code + ' ' + year.to_s
        series = Series.where(document_type: 'Sales Order', series_name: series_name)
        while SalesOrder.where(order_number: series.first.last_number).present? do
          series.first.increment_last_number
          series = Series.where(document_type: 'Sales Order', series_name: series_name)
        end
        if series.present? && sales_order.status != 'Approved'
          sales_order.update_attributes(remote_status: :'Supplier PO: Request Pending', status: :'Approved', mis_date: Date.today, order_number: series.first.last_number)
          series.first.increment_last_number
          doc_id = ::Resources::Order.create(sales_order)
          order = ::Resources::Order.find(doc_id)
          if order.present?
            sales_order.update_attributes(remote_uid: order['DocEntry'])
            company = sales_order.company
            company_so_amount = company.company_transactions_amounts.where(financial_year: Company.current_financial_year).last
            company_so_amount.increment_total_amount(sales_order.calculated_total_with_tax) if company_so_amount.present?
          end
          Services::Overseers::Inquiries::UpdateStatus.new(sales_order, :order_won).call
          comment = sales_order.inquiry.comments.create!(message: 'SAP Approved' , sales_order: sales_order)
          if sales_order.approval.blank?
            sales_order.create_approval!(comment: comment)
            sales_order.rejection.destroy! if sales_order.rejection.present?
          end
        sales_order.update_index
        end

    end
  
    attr_accessor :customer_order
  end