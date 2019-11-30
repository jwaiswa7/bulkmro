class Services::Overseers::Exporters::SalesOrderRowsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = SalesOrderRow
    @export_name = 'sales_order_rows'
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Inside Sales Person',
        'Inquiry Number',
        'Bm #',
        'Description',
        'Company Alias',
        'Order Date',
        'Order Number',
        'Qty',
        'Selling Price (As Per So / Ar Invoice)',
        'Supplier Name',
        'Total Landed Cost',
        'Margin',
        'Margin (In %)',
        'Client Order #',
        'Client Order Date',
        'Unit Price',
        'Freight',
        'Tax Type',
        'Tax Rate',
        'Tax Amount',
        'Gross Total Selling',
        'Buying Rate',
        'Buying Total',
        'Invoice Value',
        'Invoice Value With Tax',
        'So Month Code',
        'quote_type',
        'Price Currency',
        'Document Rate',
        'Company Name',
        'AR Invoice #',
        'AR Invoice Date',
        'Ar Month Code',
        'Supplier Po #',
        'AP Invoice #',
        'Qty',
        'Ap Invoice Value (Not For Margin Calculation)',
        'Cost Of Good Sold (Viz. Sales Qty)',
        'Customs',
        'International Freight',
        'Domestic Inward Logistics',
        'Domestic Warehouse',
        'Domestic Outward Logistics',
        'Type Of Customer',
        'Customer Industry',
        'Customer - Domestic / Exports',
        'Product Category',
        'Product Sub Category 1',
        'Product Sub Category 2',
        'Brand',
        'Type Of Supplier (Dvs)',
        'Supplier - Domestic / Imports',
        'Oem / Non Oem',
        'Revenue Stream',
        'Business Vertical',
        'High Value / Low Value',
        'Top 30',
        'Month Cohort First Order',
        'Quarter Cohort First Order',
        'Month Cohort Last Order',
        'Quarter Cohort Last Order',
        'Year Cohort (So Fy)_First Order',
        'Year Cohort (So Fy)_Last Order',
        'Repeat / Churn / New',
        'So Month Code',
        'So Financial Year',
        'So Quarter',
        'Ar Month Code',
        'Ar Financial Year',
        'Supplier Month Cohort First Order',
        'Supplier Quarter Cohort First Order',
        'Supplier Month Cohort Last Order',
        'Supplier Quarter Cohort Last Order',
        'Supplier Year Cohort (So Fy)_First Order',
        'Supplier Year Cohort (So Fy)_Last Order',
        'Supplier Repeat / Churn / New',
        'So Ranking',
        'Magento Company Alias Ranking',
        'Magento Supplier Ranking',
        'Selling Price (Usd Million)',
        'Landed (Usd Million)',
        'Margin (Usd Million)'
    ]
    @export.update_attributes(export_type: 35, status: 'Enqueued')
  end

  def call
    perform_export_later('SalesOrderRowsExporter')
  end

  def build_csv
    @export.update_attributes(status: 'Processing')
    model.joins(:sales_order).where('sales_orders.status = ?', SalesOrder.statuses['Approved']).where.not('sales_orders.order_number': nil).where.not('sales_orders.sales_quote_id': nil).where(created_at: start_at..end_at).order(created_at: :desc).each do |row|
      sales_order = row.sales_order
      inquiry = sales_order.inquiry

      rows.push(
        inside_sales: sales_order.inside_sales_owner.try(:full_name),
        inquiry_number: inquiry.inquiry_number,
        bm_number: row.product.sku,
        description: row.product.name,
        company_alias: inquiry.account.name,
        order_date: sales_order.created_at.to_date.to_s,
        order_number: sales_order.order_number,
        qty: row.quantity,
        selling_price: row.converted_total_selling_price,
        supplier_name: row.sales_quote_row.supplier.name,
        total_landed_cost: '',
        margin: row.total_margin,
        margin_percentage: row.margin_percentage,
        client_order: inquiry.customer_po_number,
        client_order_date: (inquiry.customer_order_date.to_date.to_s if inquiry.customer_order_date.present?),
        unit_price: row.unit_selling_price,
        freight: row.freight_cost_subtotal,
        tax_type: '', # remaining
        tax_rate: row.sales_quote_row.try(:tax_rate).try(:tax_percentage),
        tax_amount: '',
        gross_total_selling: '',
        buying_rate: row.sales_quote_row.unit_cost_price,
        buying_total: '',
        invoice_value: '',
        invoice_value_with_tax: '',
        so_month_code: '',
        quote_type: inquiry.quote_category,
        currency: inquiry.currency.name,
        conversion_rate: inquiry.inquiry_currency.conversion_rate,
        company_name: inquiry.company.name,
        AR_Invoice: sales_order.invoices.pluck(:invoice_number).join(';'),
        AR_Invoice_Date: sales_order.invoices.map{ |i| i.created_at.to_date.to_s }.join(';'),
        AR_Month_Code: '',
        Supplier_PO: sales_order.po_requests.pluck(:purchase_order_number).compact.join(';'),
        AP_Invoice: '',
        Qty: '',
        AP_Invoice_not_for_margin_calculation: '',
        Cost_of_Goods_Sold: '',
        Customs: '',
        International_Freight: '',
        Domestic_Inward_Logistics: '',
        Domestic_Warehouse: '',
        Domestic_Outward_Logistics: '',
        Type_Of_Customer: inquiry.company.company_type,
        Customer_Industry: inquiry.company.industry.try(:name),
        Customer: ((
        if inquiry.company.default_billing_address.country_code == 'IN' then
          'Domestic'
        else
          'Exports'
        end) if inquiry.company.default_billing_address.present?),
        Product_Category: (row.product.category.ancestors_to_s.first if row.product.category.present? && row.product.category.ancestors_to_s.first.present?),
        Product_Sub_Category_1: (row.product.category.ancestors_to_s.second if row.product.category.present? && row.product.category.ancestors_to_s.second.present?),
        Product_Sub_Category_2: (row.product.category.ancestors_to_s.third if row.product.category.present? && row.product.category.ancestors_to_s.third.present?),
        brand: (row.product.brand.name if row.product.brand.present?),
        Type_Of_Supplier: row.sales_quote_row.supplier.company_type,
        Supplier_Domestic_Imports: if row.sales_quote_row.supplier.default_shipping_address.try(:country_code) == 'IN' || row.sales_quote_row.supplier.addresses.first.try(:country_code) == 'IN' then
                                     'Domestic'
                                   else
                                     'Imports'
                                   end,
        Oem_Non_Oem: '',
        Revenue_Stream: '',
        Business_Vertical: '',
        HighValue_LowValue: '',
        Top_30: '',
        Month_Cohort_First_Order: '',
        Quarter_Cohort_First_Order: '',
        Month_Cohort_Last_Order: '',
        Quarter_Cohort_Last_Order: '',
        Year_Cohort_So_Fy_First_Order: '',
        Year_Cohort_So_Fy_Last_Order: '',
        Repeat_Churn_New: '',
        So_Month_Code_So_Financial_Year: '',
        So_Quarter: '',
        Ar_Month_Code: '',
        Ar_Financial_Year: '',
        Supplier_Month_Cohort_First_Order: '',
        Supplier_Quarter_Cohort_First_Order: '',
        Supplier_Month_Cohort_Last_Order: '',
        Supplier_Quarter_Cohort_Last_Order: '',
        Supplier_Year_Cohort_So_Fy_First_Order: '',
        Supplier_Year_Cohort_So_Fy_Last_Order: '',
        Supplier_Repeat_Churn_New: '',
        So_Ranking: '',
        Magento_Company_Alias_Ranking: '',
        Magento_Supplier_Ranking: '',
        Selling_Price_Usd_Million: '',
        Landed_Usd_Million: '',
        Margin_Usd_Million: ''
                )
    end
    # export = Export.create!(export_type: 35)
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
