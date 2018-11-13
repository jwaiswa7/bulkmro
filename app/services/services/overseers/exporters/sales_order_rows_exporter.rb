class Services::Overseers::Exporters::SalesOrderRowsExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = %w(
        inside_sales
        inquiry_number
        bm_number
        description
        company_alias
        order_date
        order_number
        Qty
        selling_price
        supplier_name
        total_landed_cost
        margin
        margin_percentage
        client_order
        client_order_date
        unit_price
        freight
        tax_type
        tax_rate
        tax_amount
        gross_total_selling
        buying_rate
        buying_total
        invoice_value
        invoice_value_with_tax
        so_month_code
        quote_type
        currency
        conversion_rate
        company_name
        AR_Invoice
        AR_Invoice_Date
        AR_Month_Code
        Supplier_PO
        AP_Invoice
        Qty
        AP_Invoice_not_for_margin_calculation
        Cost_of_Goods_Sold
        Customs
        International_Freight
        Domestic_Inward_Logistics
        Domestic_Warehouse
        Domestic_Outward_Logistics
        Type_Of_Customer
        Customer_Industry
        Customer
        product_category
        brand
        Type_Of_Supplier
        Supplier_Domestic_Imports
        Oem_Non_Oem
        Revenue_Stream
        Business_Vertical
        HighValue_LowValue
        Top_30
        Month_Cohort_First_Order
        Quarter_Cohort_First_Order
        Month_Cohort_Last_Order
        Quarter_Cohort_Last_Order
        Year_Cohort_So_Fy_First_Order
        Year_Cohort_So_Fy_Last_Order
        Repeat_Churn_New
        So_Month_Code_So_Financial_Year
        So_Quarter
        Ar_Month_Code
        Ar_Financial_Year
        Supplier_Month_Cohort_First_Order
        Supplier_Quarter_Cohort_First_Order
        Supplier_Month_Cohort_Last_Order
        Supplier_Quarter_Cohort_Last_Order
        Supplier_Year_Cohort_So_Fy_First_Order
        Supplier_Year_Cohort_So_Fy_Last_Order
        Supplier_Repeat_Churn_New
        So_Ranking
        Magento_Company_Alias_Ranking
        Magento_Supplier_Ranking
        Selling_Price_Usd_Million
        Landed_Usd_Million
        Margin_Usd_Million
    )
    @model = SalesOrderRow
  end

  def call
    model.status_Approved.where(:created_at => start_at..end_at).each do |row|
      sales_order = row.sales_order
      inquiry = sales_order.inquiry

      rows.push({
                    :inside_sales => sales_order.inside_sales_owner.to_s,
                    :inquiry_number => inquiry.inquiry_number,
                    :bm_number => row.product.sku,
                    :description => row.product.description,
                    :company_alias => inquiry.account.name,
                    :order_date => sales_order.created_at.to_date.to_s,
                    :order_number => sales_order.order_number,
                    :qty => row.quantity,
                    :selling_price => "",
                    :supplier_name => "",
                    :total_landed_cost => "",
                    :margin => "",
                    :margin_percentage => "",
                    :client_order => "",
                    :client_order_date => "",
                    :unit_price => row.unit_selling_price,
                    :freight => row.freight_cost_subtotal,
                    :tax_type => "",
                    :tax_rate => sales_quote_row.tax_rate,
                    :tax_amount => "",
                    :gross_total_selling => "",
                    :buying_rate => "",
                    :buying_total => "",
                    :invoice_value => "",
                    :invoice_value_with_tax => "",
                    :so_month_code => "",
                    :quote_type => inquiry.quote_category,
                    :currency => inquiry.currency.name,
                    :conversion_rate => inquiry.inquiry_currency.conversion_rate,
                    :company_name => inquiry.company.name,
                    :AR_Invoice => "",
                    :AR_Invoice_Date => "",
                    :AR_Month_Code => "",
                    :Supplier_PO => "",
                    :AP_Invoice => "",
                    :Qty => "",
                    :AP_Invoice_not_for_margin_calculation => "",
                    :Cost_of_Goods_Sold => "",
                    :Customs => "",
                    :International_Freight => "",
                    :Domestic_Inward_Logistics => "",
                    :Domestic_Warehouse => "",
                    :Domestic_Outward_Logistics => "",
                    :Type_Of_Customer => inquiry.company.company_type,
                    :Customer_Industry => inquiry.company.industry.name,
                    :Customer => "", #Doubt
                    :product_category => row.product.category.name,
                    :brand => row.product.brand.name,
                    :Type_Of_Supplier => "",
                    :Supplier_Domestic_Imports => "",
                    :Oem_Non_Oem => "",
                    :Revenue_Stream => "",
                    :Business_Vertical => "",
                    :HighValue_LowValue => "",
                    :Top_30 => "",
                    :Month_Cohort_First_Order => "",
                    :Quarter_Cohort_First_Order => "",
                    :Month_Cohort_Last_Order => "",
                    :Quarter_Cohort_Last_Order => "",
                    :Year_Cohort_So_Fy_First_Order => "",
                    :Year_Cohort_So_Fy_Last_Order => "",
                    :Repeat_Churn_New => "",
                    :So_Month_Code_So_Financial_Year => "",
                    :So_Quarter => "",
                    :Ar_Month_Code => "",
                    :Ar_Financial_Year => "",
                    :Supplier_Month_Cohort_First_Order => "",
                    :Supplier_Quarter_Cohort_First_Order => "",
                    :Supplier_Month_Cohort_Last_Order => "",
                    :Supplier_Quarter_Cohort_Last_Order => "",
                    :Supplier_Year_Cohort_So_Fy_First_Order => "",
                    :Supplier_Year_Cohort_So_Fy_Last_Order => "",
                    :Supplier_Repeat_Churn_New => "",
                    :So_Ranking => "",
                    :Magento_Company_Alias_Ranking => "",
                    :Magento_Supplier_Ranking => "",
                    :Selling_Price_Usd_Million => "",
                    :Landed_Usd_Million => "",
                    :Margin_Usd_Million => ""
                })
    end

    generate_csv
  end
end