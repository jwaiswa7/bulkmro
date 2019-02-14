class Resources::Invoice < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.set_invoice_items(sales_invoice_numbers)
    sales_invoice_numbers.each do |sales_invoice_number|
      remote_response = self.custom_find(sales_invoice_number)
      if remote_response.present?
        metadata = self.build_metadata(remote_response)

        sales_invoice = ::SalesInvoice.find_by_invoice_number(sales_invoice_number)
        if !sales_invoice.present?
          service = Services::Callbacks::SalesInvoices::Create.new(metadata, nil)
          service.call
          next
        end

        remote_rows = remote_response['DocumentLines']

        ActiveRecord::Base.transaction do
          sales_invoice.rows.destroy_all
          sales_invoice.update_attributes!(metadata: metadata)

          remote_rows.each do |remote_row|
          # is_kit = remote_row['TreeType'] == 'iSalesTree' ? true : false
          unit_price = remote_row['Price'].to_f
          sku = remote_row['ItemCode']
          product = Product.find_by_sku(sku)
          is_kit = product.present? ? product.is_kit : false

          # sales_order_row = sales_order.rows.joins(:product).where('products.sku = ?', sku).first
          quantity = remote_row['Quantity'].to_f
          tax_amount = remote_row['NetTaxAmountFC'].to_f != 0 ? remote_row['NetTaxAmountFC'].to_f : remote_row['NetTaxAmount'].to_f

          sales_invoice.rows.create!(
            quantity: quantity,
            metadata: {
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
                base_weee_tax_applied_row_amnt: nil
            }
          )
          break if is_kit
        end if remote_rows.present? end
      end
    end
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

    remote_rows.each do |remote_row|
      unit_price = remote_row['Price'].to_f
      sku = remote_row['ItemCode']
      product = Product.find_by_sku(sku)
      quantity = remote_row['Quantity'].to_f
      tax_amount = remote_row['NetTaxAmountFC'].to_f != 0 ? remote_row['NetTaxAmountFC'].to_f : remote_row['NetTaxAmount'].to_f
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
          base_weee_tax_applied_row_amnt: nil
      }
      remote_rows_arr.push(remote_row_obj)
    end
    metadata = {
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
      'increment_id' => remote_response['DocNum'],
      'sales_invoice' => {
          'created_at' => remote_response['DocDate'],
          'updated_at' => nil
      },
      'unitprice_kit' => remote_rows_arr[0][:price],
      'base_tax_amount' => remote_response['VatSum'],
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
      'base_subtotal_incl_tax' => remote_response['DocTotal'],
      'base_shipping_tax_amount' => nil,
      'shipping_hidden_tax_amount' => nil,
      'base_shipping_hidden_tax_amnt' => nil
    }
  end
end
