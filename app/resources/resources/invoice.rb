class Resources::Invoice < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.set_invoice_items(sales_invoice)
    remote_response = self.custom_find(sales_invoice.invoice_number)
    if remote_response.present?
      remote_rows = remote_response['DocumentLines']
      sales_order = sales_invoice.sales_order

      metadata_changes = {
          subtotal: remote_response['DocTotal'] - remote_response['VatSum'],
          tax_amount: remote_response['VatSum'],
          subtotal_incl_tax: remote_response['DocTotal'],
          rate: remote_response['DocRate']
      }

      ActiveRecord::Base.transaction do
        sales_invoice.rows.destroy_all
        sales_invoice.update_attributes!(metadata: sales_invoice.metadata.merge!(metadata_changes))

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
        end if remote_rows.present?
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
end
