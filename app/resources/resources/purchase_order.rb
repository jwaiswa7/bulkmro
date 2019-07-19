class Resources::PurchaseOrder < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.set_multiple_items(purchase_order_numbers, filter_params = nil)
    purchase_order_numbers.each do |purchase_order_number|
      if filter_params.present?
        remote_response = self.custom_find_with_filters(purchase_order_number, filter_params[:"#{purchase_order_number.to_s}"])
        if remote_response.present?
          metadata = self.build_metadata(remote_response)
          metadata['PoNum'] = (purchase_order_number.to_s + '0').to_i
          purchase_order = ::PurchaseOrder.find_by_po_number(metadata['PoNum'])
          if !purchase_order.present?
            service = Services::Callbacks::PurchaseOrders::Create.new(metadata, nil)
            service.call
            next
          end
        end
      else
        remote_response = self.custom_find(purchase_order_number)
        if remote_response.present?
          metadata = self.build_metadata(remote_response)

          purchase_order = ::PurchaseOrder.find_by_po_number(purchase_order_number)
          if !purchase_order.present?
            service = Services::Callbacks::PurchaseOrders::Create.new(metadata, nil)
            service.call
            next
          end

          purchase_order.assign_attributes(metadata: metadata)
          if metadata['PoStatus'].to_i > 0
            purchase_order.assign_attributes(status: metadata['PoStatus'].to_i)
          else
            purchase_order.assign_attributes(status: ::PurchaseOrder.statuses[metadata['PoStatus']])
          end

          ActiveRecord::Base.transaction do
            # purchase_order.rows.destroy_all
            purchase_order.update_attributes!(metadata: metadata)

            metadata['ItemLine'].each do |remote_row|
              row = purchase_order.rows.select { |por| por.metadata['Linenum'].to_i == remote_row['Linenum'].to_i }.first

              if row.present?
                row.assign_attributes(metadata: remote_row)
                row.save!
              else
                new_row = purchase_order.rows.build do |po_row|
                  po_row.assign_attributes(
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

  def self.custom_find_with_filters(doc_num, filter_params)
    filters_query = "DocNum eq #{doc_num}"
    filter_params.map {|k, v| filters_query << ' and ' + k.to_s + ' eq ' + "'#{v}'"}
    response = get("/#{collection_name}?$filter=#{filters_query}")
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
          'PopProductId' => (product.to_param if product.present?),
          'PopPriceHtBase' => row['UnitPrice'],
          'PopProductName' => row['ItemDescription'],
          'PopSuppliedQty' => row['PackageQuantity'],
          'PopDeliveryDate' => row['DocDueDate']
      }
      remote_rows_arr.push(remote_row_obj)
    end
    {
        'PoNum' => remote_response['DocNum'],
        'PoDate' => remote_response['DocDate'],
        'PoType' => remote_response['Movement of Goods'],
        'DocEntry' => remote_response['DocEntry'],
        'PoPaymentTerms' => remote_response['PaymentGroupCode'],
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
        'PoCurrencyChangeRate' => remote_response['DocRate'] || "1",
        'PoModeOfTrasport' => PurchaseOrder.transport_modes.key(remote_response['ShippingMethod'].to_i),
        'LineTotal' => freight,
        'TaxSum' => freight_tax
    }
  end

  def self.to_remote(record, po_request)
    item_row = []
    po_request.rows.each do |row|
      json = {
          ItemCode: row.product.sku,
          DiscountPercent: row.discount_percentage,
          Quantity: row.quantity.to_f,
          ProjectCode: po_request.inquiry.inquiry_number,
          UnitPrice: row.unit_price.to_f,
          Currency: po_request.sales_order.currency.name,
          TaxCode: row.taxation.to_remote_s, # row.tax_rate.to_s.gsub('.0%', '').gsub('GST ', 'GST@'),
          HSNEntry: row.product.is_service ? nil : row.tax_code.remote_uid,
          SACEntry: row.product.is_service ? row.tax_code.remote_uid : nil,
          WarehouseCode: po_request.bill_to.remote_uid,
          LocationCode: po_request.bill_to.location_uid,
          MeasureUnit: row.measurement_unit.name,
          U_ProdBrand: row.brand_id.present? ? row.brand.name : row.product.brand.name
      }
      item_row << json
    end

    {
        PoDate: Time.now.strftime('%Y-%m-%d'),
        PoStatus: '63',
        DocNum: record.po_number,
        HandWritten: "tYES",
        PoSupNum: '',
        PoSupBillFrom: po_request.supplier.billing_address.remote_uid,
        PoSupShipFrom: po_request.supplier.shipping_address.remote_uid,
        PoShippingCost: '0',
        PoTargetWarehouse: po_request.ship_to.remote_uid,
        DocumentLines: item_row,
        BPL_IDAssignedToInvoice: po_request.bill_to.remote_branch_code, # warehouse Id
        Project: po_request.inquiry.inquiry_number,
        CardCode: po_request.supplier.remote_uid,
        CardName: po_request.supplier.to_s,
        DocDate: Time.now.strftime('%Y-%m-%d'),
        ProjectCode: po_request.inquiry.inquiry_number,
        NumAtCard: '',
        DocCurrency: po_request.sales_order.currency.name,
        TaxDate: Time.now.strftime('%Y-%m-%d'),
        DocDueDate: Time.now.strftime('%Y-%m-%d'),
        U_SalesMgr: po_request.inquiry.sales_manager.to_s,
        U_In_Sales_Own: po_request.inquiry.inside_sales_owner.to_s,
        U_Out_Sales_Own: po_request.inquiry.inside_sales_owner.to_s,
        U_CnfrmAddB: 'A',
        U_CnfrmAddS: 'A',
        U_BM_BillFromTo: po_request.bill_to.remote_uid
    }
  end
end
