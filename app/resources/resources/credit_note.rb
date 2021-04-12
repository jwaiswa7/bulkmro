class Resources::CreditNote < Resources::ApplicationResource
  def self.identifier
    :DocNum
  end

  def self.create_from_sap(next_page_url = nil)
    response = get("/#{collection_name}#{next_page_url}")
    validated_response = get_validated_response(response)
    next_page = validated_response['odata.nextLink']&.gsub('/b1s/v1/CreditNotes', '')

    return unless validated_response['value'].present?

    if next_page.present?
      SaveAndSyncCreditNoteJob.perform_later(next_page)
    end

    validated_response['value'].each do |sap_credit_memo|
      metadata = self.build_metadata(sap_credit_memo)
      service = Services::Callbacks::CreditNotes::Create.new(metadata, nil)
      service.call
      next
    end
  end

  def self.search_or_create(memo_number)
    response = custom_find(memo_number)
    metadata = build_metadata(response)
    service = Services::Callbacks::CreditNotes::Create.new(metadata, nil)
    service.call
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

    company = Company.acts_as_customer.find_by_remote_uid(remote_response['CardCode'])
    company_total_amount = company&.get_company_total_amount
    remote_rows.each do |remote_row|
      unit_price = remote_row['Price'].to_f
      sku = remote_row['ItemCode']
      product = Product.find_by_sku(sku)
      quantity = remote_row['Quantity'].to_f

      if company_total_amount.present? && company_total_amount > (Settings&.tcs&.tcs_threshold).to_f
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
      'controller' => 'callbacks/credit_notes',
      'memo_number' => remote_response['DocNum'],
      'memo_date' => remote_response['DocDate'].to_date,
      'memo_amount' => remote_response['DocTotal'],
      'invoice_number' => remote_response['OriginalRefNo'],
      'metadata' => {
        'increment_id' => remote_response['DocNum'],
        'base_grand_total' => remote_response['DocTotal'],
        'base_to_order_rate' => remote_response['DocRate'],
        'base_currency_code' => remote_response['DocCurrency'],
        'lineItems' => remote_rows_arr
      }
    }
  end
end
