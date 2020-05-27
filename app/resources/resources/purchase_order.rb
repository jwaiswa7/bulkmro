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
        'PoShipWarehouse' => remote_response['DocumentLines'][0]['WarehouseCode'],
        'PoBillingAddress' => remote_response['PayToCode'],
        'po_sales_manager' => remote_response['U_SalesMgr'],
        'PoTargetWarehouse' => remote_response['U_BM_BillFromTo'],
        'po_overall_margin' => remote_response['U_Ovr_Margin'],
        'PoPackingForwarding' => remote_response['U_PackFwd'],
        'PoCurrencyChangeRate' => remote_response['DocRate'] || "1",
        'PoModeOfTrasport' => (PurchaseOrder.transport_modes.key(remote_response['DocumentLines'][0]['ShippingMethod'].to_i)) || 'Road',
        'LineTotal' => freight,
        'TaxSum' => freight_tax
    }
  end

  def self.to_remote(record, po_request)
    item_row = []
    po_request_pur = po_request.sales_order.present? ? 1 : 2
    po_request.rows.each do |row|
      json = {
          ItemCode: row.product.sku,
          DiscountPercent: row.discount_percentage,
          Quantity: row.quantity.to_f,
          ProjectCode: po_request.inquiry.inquiry_number,
          UnitPrice: row.unit_price.to_f,
          Currency: po_request.inquiry.currency.name,
          TaxCode: row.taxation.to_remote_s, # row.tax_rate.to_s.gsub('.0%', '').gsub('GST ', 'GST@'),
          HSNEntry: row.product.is_service ? nil : row.tax_code.remote_uid,
          SACEntry: row.product.is_service ? row.tax_code.remote_uid : nil,
          WarehouseCode: po_request.ship_to.remote_uid,
          LocationCode: po_request.ship_to.location_uid,
          MeasureUnit: row.measurement_unit.name,
          U_ProdBrand: row.brand_id.present? ? row.brand.try(:name) : row.product.brand.try(:name)
      }
      item_row << json
    end
    product_ids = Product.where(sku: Settings.product_specific.freight).last.id
    company_contact = CompanyContact.where(company_id: po_request.supplier_id, contact_id: po_request.contact_id).last
    {
        PoDate: po_request.purchase_order.present? ? po_request.purchase_order.created_at.strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        PoStatus: '63',
        DocNum: record.po_number,
        HandWritten: "tYES",
        PoSupNum: '',
        PayToCode: po_request.bill_from.remote_uid,
        ShipFrom: po_request.ship_from.remote_uid,
        PoFreight: po_request.rows.pluck(:product_id).include?(product_ids) ? 'Excluded' : 'Included',
        PoShippingCost: '0',
        PoTargetWarehouse: po_request.ship_to.remote_uid,
        DocumentLines: item_row,
        BPL_IDAssignedToInvoice: po_request.bill_to.remote_branch_code, # warehouse Id
        Project: po_request.inquiry.inquiry_number,
        CardCode: po_request.supplier.remote_uid,
        CardName: po_request.supplier.to_s,
        DocDate: po_request.purchase_order.present? ? po_request.purchase_order.created_at.strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        ProjectCode: po_request.inquiry.inquiry_number,
        NumAtCard: '',
        DocCurrency: po_request.inquiry.currency.name,
        TaxDate: Time.now.strftime('%Y-%m-%d'),
        DocDueDate: po_request.rows.present? ? po_request.rows.maximum(:lead_time).strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        U_SalesMgr: po_request.inquiry.sales_manager.to_s,
        U_In_Sales_Own: po_request.inquiry.inside_sales_owner.to_s,
        U_Out_Sales_Own: po_request.inquiry.inside_sales_owner.to_s,
        U_BM_BillFromTo: po_request.bill_to.remote_uid,
        CntctCode: company_contact.present? ? company_contact.remote_uid : '',
        TransportationCode: po_request.transport_mode.present? ? PoRequest.transport_modes[po_request.transport_mode.to_sym] : 1,
        U_TrmDeli: po_request.delivery_type.present? ? po_request.delivery_type.to_s : 'Door Delivery',
        U_PO_Pur: po_request_pur,
        PaymentGroupCode: po_request.payment_option.present? ? po_request.payment_option.remote_uid : '',
        U_CnfrmQty: 'A',
        U_CnfrmAddB: 'A',
        U_CnfrmAddS: 'A',
        U_CnfrmRate: 'A',
        U_CnfirmTax: 'A',
        U_CnfrmGross: 'A',
        U_Cnfrm_GSTIN: 'A',
        U_Cnfrm_PayTerm: 'A',
        U_CnfrmDscrMPN: 'A',
        U_CnfrmTotal: 'A',
        U_CnfrmHSN: 'A',
        U_CnfrmTaxTYpe: 'A',
        U_CnfrmPrice: 'A',
        U_TermCondition: po_request.commercial_terms_and_conditions
    }
  end

  def self.update(id, record, quotes: false)
    url = "/#{collection_name}(#{quotes ? ["'", id, "'"].join : id})"
    body = to_remote(record, record.po_request).to_json
    response = perform_remote_sync_action('patch', url, body)
    log_request(:patch, record, record.po_request)
    validated_response = get_validated_response(response)

    log_response(validated_response, 'patch', url, body)

    yield validated_response if block_given?
    id
  end

  def self.create_approval(remote_uid)
    url = "/#{collection_name}(#{remote_uid})"
    body = {
        U_CnfrmQty: 'A',
        U_CnfrmAddB: 'A',
        U_CnfrmAddS: 'A',
        U_CnfrmRate: 'A',
        U_CnfirmTax: 'A',
        U_CnfrmGross: 'A',
        U_Cnfrm_GSTIN: 'A',
        U_Cnfrm_PayTerm: 'A',
        U_CnfrmDscrMPN: 'A',
        U_CnfrmTotal: 'A',
        U_CnfrmHSN: 'A',
        U_CnfrmTaxTYpe: 'A',
        U_CnfrmPrice: 'A'
    }
    response = perform_remote_sync_action('patch', url, body.to_json)
    puts response
  end
end
