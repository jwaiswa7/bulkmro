class Services::Shared::Migrations::SoPoMigrations < Services::Shared::Migrations::Migrations

  #s = Services::Shared::Migrations::SoPoMigrations.new
  #s.set_warehouse_series

  def set_warehouse_series
    service = Services::Shared::Spreadsheets::CsvImporter.new('document_series2020.csv', 'seed_files_3')
    data_not_done = []
    service.loop(nil) do |x|
      p x.get_column('period_ document_type')
      series = Series.where(series_name: x.get_column('series_name'), document_type: x.get_column('document_type'),period_indicator: x.get_column('period_indicator')).last
      if !series.present? && (Series.document_types.keys.include? x.get_column('document_type'))
        s = Series.new(document_type: x.get_column('document_type'),
                       series: x.get_column('first_number').to_s.first(3).to_i,
                       series_name: x.get_column('series_name'),
                       period_indicator: x.get_column('period_indicator'),
                       number_length: x.get_column('length').to_i,
                        first_number: x.get_column('first_number'),
                        last_number: x.get_column('first_number'))
        p '******************8'
        # p s.errors.full_message
        s.save(validate: false)
        p '******************8'
      else
        data_not_done << {series_name: x.get_column('series_name'), first_number: x.get_column('first_number')}
      end
      p data_not_done
    end
  end

  def last_number_updation
    start_date = '1-4-2019'.to_datetime
    end_date = Date.today.end_of_day
    Series.all.each do |series|
      if series.last_number.nil? && series.first_number.present?
        # series.update_attributes(json)
        document_type = series.document_type
        case document_type
        when 'Sales Order'
          sales_order = SalesOrder.where(created_at: start_date..end_date).where(order_number: series.first_number..(series.first_number + 9998)).order(:order_number).last
          if sales_order.present?
            order_number = sales_order.order_number
            series.update_attributes(last_number: (order_number + 1))
          else
            series.update_attributes(last_number: (series.first_number))
          end
        when 'Purchase Order'
          purchase_order = PurchaseOrder.where(created_at: start_date..end_date).where(po_number: series.first_number..(series.first_number + 9998)).order(:po_number).last
          if purchase_order.present?
            po_number = purchase_order.po_number
            series.update_attributes(last_number: (po_number + 1))
          else
            series.update_attributes(last_number: (series.first_number))
          end
        end
      end
    end
  end

  def series_code_in_warehouses
    service = Services::Shared::Spreadsheets::CsvImporter.new('warehouse_codes.csv', 'seed_files_3')
    service.loop(nil) do |x|
      warehouse_name = x.get_column('Warehouse Name')
      code = x.get_column('Series Code')
      if warehouse_name.present?
        warehouse = Warehouse.find_by_name(warehouse_name)
        if warehouse.present?
          warehouse.series_code = code
          warehouse.save
        end
      end
    end
  end

  def set_last_number_in_series
    service = Services::Shared::Spreadsheets::CsvImporter.new('warehouse_codes.csv', 'seed_files_3')
    service.loop(nil) do |x|
      document_type = x.get_column('document_type')
      series_name = x.get_column('series_name')
      last_number = x.get_column('last_number')

      series = Series.where(document_type: document_type, series_name: series_name).first

      if series.present?
        series.update_attributes(last_number: last_number)
      end
    end
  end

  def po_delivery_type_mismatch
    PoRequest.where(delivery_type: 100).each do |po_request|
      if po_request.purchase_order.present?
        if (po_request.delivery_type != po_request.purchase_order.delivery_type) && (po_request.delivery_type != po_request.purchase_order.metadata["PoDeliveryTerms"])
          po_request.purchase_order.delivery_type =  po_request.delivery_type
          po_request.purchase_order.metadata["PoDeliveryTerms"] = po_request.delivery_type
          po_request.purchase_order.save
        else
          po_request.purchase_order.update_attributes(delivery_type: po_request.delivery_type)
        end
      end
    end
  end
end
