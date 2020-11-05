class Resources::SalesInvoice < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.set_multiple_items(sales_invoice_numbers)
    sales_invoice_numbers.each do |sales_invoice_number|
      remote_response = self.custom_find(sales_invoice_number)
      if remote_response.present?

        sales_invoice = ::SalesInvoice.find_by_invoice_number(sales_invoice_number)
        metadata = self.build_metadata(remote_response)

        if !sales_invoice.present?
          service = Services::Callbacks::SalesInvoices::Create.new(metadata, nil)
          service.call
          next
        end

        remote_rows = remote_response['DocumentLines']

        ActiveRecord::Base.transaction do
          sales_invoice.rows.where(sku: nil).destroy_all

          billing_address = sales_invoice.inquiry.billing_company.addresses.where(remote_uid: remote_response['PayToCode']).first || sales_invoice.inquiry.billing_address
          shipping_address = sales_invoice.inquiry.shipping_company.addresses.where(remote_uid: remote_response['ShipToCode']).first || sales_invoice.inquiry.shipping_address
          sales_invoice.update_column(:metadata, metadata)
          sales_invoice.update_attributes!(billing_address: billing_address, shipping_address: shipping_address)
          remote_rows.each do |remote_row|
            # is_kit = remote_row['TreeType'] == 'iSalesTree' ? true : false
            unit_price = remote_row['Price'].to_f
            sku = remote_row['ItemCode']
            product = Product.find_by_sku(sku)
            is_kit = product.present? ? product.is_kit : false

            # sales_order_row = sales_order.rows.joins(:product).where('products.sku = ?', sku).first
            quantity = remote_row['Quantity'].to_f
            sales_invoice_row = sales_invoice.rows.where(sku: sku).first_or_initialize
            sales_invoice_row.quantity = quantity
            sales_invoice_row.sku = sku
            company = sales_invoice.company
            tcs_applicable = company.check_company_total_amount(sales_invoice)
            if tcs_applicable && product.is_service != true
              tax_remote_row = remote_row['LineTaxJurisdictions'].select { |tax_jurisdiction| tax_jurisdiction['JurisdictionType'] != 8 }
              tcs_amount_row = remote_row['LineTaxJurisdictions'].select { |tax_jurisdiction| tax_jurisdiction['JurisdictionType'] == 8 }
              tcs_amount = tcs_amount_row.present? ? tcs_amount_row[0]['TaxAmount'] : 0.0
              if remote_row['TaxCode'].include?('IG')
                tax_amount = tax_remote_row[0]['TaxAmountFC'].to_f != 0 ? tax_remote_row[0]['TaxAmountFC'].to_f : tax_remote_row[0]['TaxAmount'].to_f
              else
                tax_amount = (tax_remote_row[0]['TaxAmountFC'].to_f != 0 ? tax_remote_row[0]['TaxAmountFC'].to_f : tax_remote_row[0]['TaxAmount'].to_f) * 2
              end
            else
              tax_amount = remote_row['TaxTotal'].to_f != 0 ? remote_row['TaxTotal'].to_f : remote_row['TaxTotal'].to_f
            end
            sales_invoice_row.metadata = {
                  qty: quantity,
                  sku: sku,
                  name: remote_row['U_Item_Descr'] != '' ? remote_row['U_Item_Descr'] : remote_row['ItemDescription'],
                  price: unit_price,
                  base_cost: nil,
                  row_total: unit_price * quantity,
                  base_price: unit_price,
                  product_id: (product.present? ? product.id.to_param : ''),
                  tax_amount: tax_amount,
                  description: remote_row['ItemDescription'],
                  order_item_id: nil,
                  base_row_total: unit_price * quantity,
                  price_incl_tax: nil,
                  additional_data: nil,
                  base_tax_amount: tax_amount,
                  discount_amount: nil,
                  weee_tax_applied: nil,
                  hidden_tax_amount: nil,
                  row_total_incl_tax: (unit_price * quantity) + (tax_amount),
                  base_price_incl_tax: (unit_price + (tax_amount / quantity)),
                  base_discount_amount: nil,
                  weee_tax_disposition: nil,
                  base_hidden_tax_amount: nil,
                  base_row_total_incl_tax: (unit_price * quantity) + (tax_amount),
                  weee_tax_applied_amount: nil,
                  weee_tax_row_disposition: nil,
                  base_weee_tax_disposition: nil,
                  weee_tax_applied_row_amount: nil,
                  base_weee_tax_applied_amount: nil,
                  base_weee_tax_row_disposition: nil,
                  base_weee_tax_applied_row_amnt: nil,
                  tcs_amount: (tcs_amount.present? ? tcs_amount : 0.0)
              }
            sales_invoice_row.save
            break if is_kit
          end if remote_rows.present?
        end
      end
    end
  end

  def self.model_name
    'Invoice'
  end

  def self.custom_find(doc_num)
    response = get("/#{collection_name}?$filter=DocNum eq #{doc_num}")
    log_request(:get, 'Invoice - #{doc_num}', is_find: true)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
    end

    remote_record
  end

  def self.build_metadata(remote_response)
    remote_rows = remote_response['DocumentLines']
    remote_rows_arr = []

    input = remote_response['Comments']
    re1 = '.*?' # Non-greedy match on filler
    re2 = '(Orders)' # Word 1
    re3 = '( )' # White Space 1
    re4 = '(\\d+)' # Integer Number 1

    re = (re1 + re2 + re3 + re4)
    m = Regexp.new(re, Regexp::IGNORECASE)
    if m.match?(input)
      order_number = m.match(input)[3]
    end

    company = Company.acts_as_customer.find_by_name(remote_response['CardName'])
    company_total_amount = company.get_company_total_amount
    remote_rows.each do |remote_row|
      unit_price = remote_row['Price'].to_f
      sku = remote_row['ItemCode']
      product = Product.find_by_sku(sku)
      quantity = remote_row['Quantity'].to_f

      if company_total_amount.present? && company_total_amount > 5000000.0
        tax_remote_row = remote_row['LineTaxJurisdictions'].select { |tax_jurisdiction| tax_jurisdiction['JurisdictionType'] != 8 }
        tcs_amount_row = remote_row['LineTaxJurisdictions'].select { |tax_jurisdiction| tax_jurisdiction['JurisdictionType'] == 8 }
        tcs_amount = tcs_amount_row.present? ? tcs_amount_row[0]['TaxAmount'] : 0.0
        if remote_row['TaxCode'].include?('IG')
          tax_amount = tax_remote_row[0]['TaxAmountFC'].to_f != 0 ? tax_remote_row[0]['TaxAmountFC'].to_f : tax_remote_row[0]['TaxAmount'].to_f
        else
          tax_amount = (tax_remote_row[0]['TaxAmountFC'].to_f != 0 ? tax_remote_row[0]['TaxAmountFC'].to_f : tax_remote_row[0]['TaxAmount'].to_f) * 2
        end
      else
        tax_amount = remote_row['NetTaxAmountFC'].to_f != 0 ? remote_row['NetTaxAmountFC'].to_f : remote_row['NetTaxAmount'].to_f
      end
      remote_row_obj = {
          qty: quantity,
          sku: sku,
          name: remote_row['U_Item_Descr'] != '' ? remote_row['U_Item_Descr'] : remote_row['ItemDescription'],
          price: unit_price,
          base_cost: nil,
          row_total: unit_price * quantity,
          base_price: unit_price,
          product_id: (product.present? ? product.id.to_param : ''),
          tax_amount: tax_amount,
          description: remote_row['ItemDescription'],
          order_item_id: nil,
          base_row_total: unit_price * quantity,
          price_incl_tax: nil,
          additional_data: nil,
          base_tax_amount: tax_amount,
          tax_code: remote_row['HSNEntry'] || remote_row['SACEntry'],
          discount_amount: nil,
          weee_tax_applied: nil,
          hidden_tax_amount: nil,
          row_total_incl_tax: (unit_price * quantity) + (tax_amount),
          base_price_incl_tax: (unit_price + (tax_amount / quantity)),
          base_discount_amount: nil,
          weee_tax_disposition: nil,
          base_hidden_tax_amount: nil,
          base_row_total_incl_tax: (unit_price * quantity) + (tax_amount),
          weee_tax_applied_amount: nil,
          weee_tax_row_disposition: nil,
          base_weee_tax_disposition: nil,
          weee_tax_applied_row_amount: nil,
          base_weee_tax_applied_amount: nil,
          base_weee_tax_row_disposition: nil,
          base_weee_tax_applied_row_amnt: nil,
          tcs_amount: (tcs_amount.present? ? tcs_amount : 0.0)
      }
      remote_rows_arr.push(remote_row_obj)
    end
    {
        'state' => remote_response['U_Invoic_Status'],
        'is_kit' => '',
        'qty_kit' => remote_rows_arr[0][:qty],
        'ItemLine' => remote_rows_arr,
        'desc_kit' => remote_response['ItemDescription'],
        'order_id' => order_number,
        'store_id' => nil,
        'doc_entry' => remote_response['DocEntry'],
        'price_kit' => remote_rows_arr[0][:price],
        'controller' => 'callbacks/sales_invoices',
        'created_at' => remote_response['DocDate'],
        'grand_total' => remote_response['DocTotal'],
        'bill_from' => remote_response['U_BM_BillFromTo'],
        'base_tax_code' => remote_response['DocumentLines'].present? ? remote_response['DocumentLines'][0]['TaxCode'] : '',
        'increment_id' => remote_response['DocNum'],
        'sales_invoice' => {
            'created_at' => remote_response['DocDate'],
            'updated_at' => nil
        },
        'unitprice_kit' => remote_rows_arr[0][:price],
        'base_tax_amount' => remote_rows_arr.pluck(:base_tax_amount).compact.sum,
        'discount_amount' => '',
        'shipping_amount' => nil,
        'base_grand_total' => remote_response['DocTotal'],
        'customer_company' => nil,
        'hidden_tax_amount' => nil,
        'shipping_incl_tax' => nil,
        'base_currency_code' => remote_response['DocCurrency'],
        'base_to_order_rate' => remote_response['DocRate'],
        'billing_address_id' => remote_response['PayToCode'],
        'order_currency_code' => remote_response['DocCurrency'],
        'shipping_address_id' => remote_response['ShipToCode'],
        'shipping_tax_amount' => nil,
        'store_currency_code' => '',
        'store_to_order_rate' => '',
        'base_discount_amount' => nil,
        'base_shipping_amount' => nil,
        'discount_description' => nil,
        'base_hidden_tax_amount' => nil,
        'base_shipping_incl_tax' => nil,
        'base_subtotal_incl_tax' => remote_rows_arr.pluck(:base_row_total_incl_tax).compact.sum,
        'base_shipping_tax_amount' => nil,
        'shipping_hidden_tax_amount' => nil,
        'base_shipping_hidden_tax_amnt' => nil,
        'tcs_amount' => remote_rows_arr.pluck(:tcs_amount).compact.sum
    }
  end
end
