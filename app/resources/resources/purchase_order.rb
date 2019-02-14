class Resources::PurchaseOrder < Resources::ApplicationResource

  def self.identifier
    :DocEntry
  end

  def self.set_purchase_order_items(purchase_order_numbers)
    purchase_order_numbers.each do |purchase_order_number|
      remote_response = self.custom_find(purchase_order_number)
      if remote_response.present?
        metadata = self.build_metadata(remote_response)

        purchase_order = ::PurchaseOrder.find_by_po_number(purchase_order_number)
        if !purchase_order.present?
          service = Services::Callbacks::PurchaseOrders::Create.new(metadata, nil)
          service.call
          next
        end

        purchase_order.assign_attributes(:metadata => metadata)
        if metadata['PoStatus'].to_i > 0
          purchase_order.assign_attributes(:status => metadata['PoStatus'].to_i)
        else
          purchase_order.assign_attributes(:status => ::PurchaseOrder.statuses[metadata['PoStatus']])
        end

        ActiveRecord::Base.transaction do
          # purchase_order.rows.destroy_all
          purchase_order.update_attributes!(:metadata => metadata)

          metadata['ItemLine'].each do |remote_row|
            row = purchase_order.rows.select {|por| por.metadata['Linenum'].to_i == remote_row['Linenum'].to_i}.first

            if row.present?
              row.assign_attributes(metadata: remote_row)
              row.save!
            else
              new_row = purchase_order.rows.build do |row|
                row.assign_attributes(
                    metadata: remote_row
                )
              end
              new_row.save!
            end
          end
          purchase_order.save!
        end
      end
    end
  end

  def self.custom_find(doc_num)
    response = get("/#{collection_name}?$filter=DocNum eq #{doc_num}")
    log_request(:get, 'Purchase Order - #{doc_num}', is_find: true)
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
    freight = remote_response['DocumentAdditionalExpenses'].present? ? remote_response['DocumentAdditionalExpenses'].first['LineTotal'].to_f : 0.0
    freight_tax = remote_response['DocumentAdditionalExpenses'].present? ? remote_response['DocumentAdditionalExpenses'].first['TaxSum'].to_f : 0.0
    remote_rows.each do |row|
      tax_code = TaxCode.find_by_remote_uid(row['HSNEntry'].to_i)
      product = Product.find_by_sku(row['ItemCode'])
      remote_row_obj = {
          'PopHsn' => tax_code.try(:chapter),
          'PopQty' => row['Quantity'],
          'Linenum' => row['LineNum'],
          'UnitMsr' => row['UoMCode'],
          'WhsCode' => row['WarehouseCode'],
          'PopPriceHt' => row['Price'],
          'PopTaxRate' => (row['TaxCode'].present? ? row['TaxCode'] : ''),
          'PriceBefDi' => row['Price'],
          'PopDiscount' => row['DiscountPercent'],
          'PopOrderNum' => row['DocNum'],
          'PopProductId' => ( product.to_param if product.present? ),
          'PopPriceHtBase' => row['UnitPrice'],
          'PopProductName' => row['ItemDescription'],
          'PopSuppliedQty' => row['PackageQuantity'],
          'PopDeliveryDate' => row['DocDueDate']
      }
      remote_rows_arr.push(remote_row_obj)
    end
    metadata = {
        'PoNum' => remote_response['DocNum'],
        'PoDate' => remote_response['DocDate'],
        'PoType' => remote_response['Movement of Goods'],
        'DocEntry' => remote_response['DocEntry'],
        'PoPaymentTerms' => '',
        'ItemLine' => remote_rows_arr,
        'PoStatus' => remote_response['U_PO_Status'],
        'PoSupNum' => remote_response['CardCode'],
        'PoFreight' => remote_response['U_Frghtterm'],
        'PoOrderId' => remote_response['U_MgntDocID'],
        'PoRemarks' => remote_response['U_TermCondition'],
        'PoTaxRate' => remote_response['TaxCode'],
        'PoComments' => remote_response['Comments'],
        'PoCurrency' => remote_response['DocCurrency'],
        'PoEnquiryId' => remote_response['Project'],
        'PoUpdatedAt' => remote_response['UpdateDate'],
        'PoSupplyDate' => remote_response['DocDueDate'],
        'PoInvoiceDate' => remote_response['DocDate'],
        'PoPaymentDate' => remote_response['DocDate'],
        'PoPaymentType' => remote_response['U_PmntMthd'],
        'PoSupBillFrom' => remote_response['PayToCode'],
        'PoSupShipFrom' => remote_response['ShipToCode'],
        'PoCommittedDate' => remote_response['U_CustComDt'],
        'PoDeliveryTerms' => remote_response['U_TrmDeli'],
        'PoShipWarehouse' => remote_response['U_BM_BillFromTo'],
        'PoBillingAddress' => remote_response['PayToCode'],
        'po_sales_manager' => remote_response['U_SalesMgr'],
        'PoTargetWarehouse' => remote_response['U_BM_BillFromTo'],
        'po_overall_margin' => remote_response['U_Ovr_Margin'],
        'PoPackingForwarding' => remote_response['U_PackFwd'],
        'PoCurrencyChangeRate' => remote_response['DocRate'],
        'LineTotal' => freight,
        'TaxSum' => freight_tax
    }
  end
end