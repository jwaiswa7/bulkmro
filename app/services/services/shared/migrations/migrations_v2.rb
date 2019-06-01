class Services::Shared::Migrations::MigrationsV2 < Services::Shared::Migrations::Migrations
  def fetch_csv(filename, csv_data)
    overseer = Overseer.find(197)
    temp_file = File.open(Rails.root.join('tmp', filename), 'wb')

    begin
      temp_file.write(csv_data)
      temp_file.close
      overseer.file.attach(io: File.open(temp_file.path), filename: filename)
      overseer.save!
      puts Rails.application.routes.url_helpers.rails_blob_path(overseer.file, only_path: true)
    rescue => ex
      puts ex.message
    end
  end

  def create_ifsc_code
    service = Services::Shared::Spreadsheets::CsvImporter.new('ifsc_code_list.csv', 'seed_files')
    service.loop(nil) do |x|
      Chewy.strategy(:bypass) do
        IfscCode.where(ifsc_code: x.get_column('IFSC')).first_or_create do |ifsc|
          ifsc.bank_id = Bank.where(name: x.get_column('BANK')).present? ? Bank.where(name: x.get_column('BANK')).last.id : nil
          ifsc.branch = x.get_column('BRANCH')
          ifsc.address = x.get_column('ADDRESS')
          ifsc.city = x.get_column('CITY')
          ifsc.district = x.get_column('DISTRICT')
          ifsc.contact = x.get_column('CONTACT')
          ifsc.state = x.get_column('STATE')
        end
      end
    end
  end

  def missing_bible_orders
    column_headers = ['inquiry_number', 'order_number']
    i = 0
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |csv|
      service.loop(nil) do |x|
        order_number = x.get_column('So #')
        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          sales_order = SalesOrder.find_by_old_order_number(x.get_column('So #'))
          if sales_order.blank?
            csv << [x.get_column('Inquiry Number'), x.get_column('So #')]
          end
          i = i + 1
          puts "line #{i}, SO #{x.get_column('So #')}"
        end
      end
    end

    fetch_csv('bible_missing_orders.csv', csv_data)
  end

  def sap_sales_order_totals_mismatch
    column_headers = ['order_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_so.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('#')) || SalesOrder.find_by_old_order_number(x.get_column('#'))
        sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f

        if sales_order.present?
          actual_total = sales_order.calculated_total.to_f
          actual_total_with_tax = sales_order.calculated_total_with_tax.to_f

          if ((actual_total != sap_total_without_tax) || (actual_total_with_tax != x.get_column('Document Total').to_f)) &&
              ((actual_total - sap_total_without_tax).abs > 1 || (actual_total_with_tax - x.get_column('Document Total').to_f).abs > 1)
            writer << [sales_order.order_number, actual_total, actual_total_with_tax, sap_total_without_tax, x.get_column('Document Total').to_f]
          end
        end
      end
    end

    fetch_csv('sales_orders_total_mismatch.csv', csv_data)
  end

  def bible_sales_order_totals_mismatch
    column_headers = ['inquiry_number', 'order_number', 'SKU', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']
    skipped_skus = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        bible_order_row_total = x.get_column('Total Selling Price').to_f
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = bible_order_row_total + bible_order_tax_total

        sales_order = SalesOrder.find_by_old_order_number(x.get_column('So #')) || SalesOrder.find_by_order_number(x.get_column('So #').to_i)
        if sales_order.present?
          product_sku = x.get_column('Bm #').to_s

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price
            row_total_with_tax = order_row.total_selling_price_with_tax

            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)
              writer << [x.get_column('Inquiry Number'), sales_order.order_number, product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax]
            end
          else
            if !(skipped_skus.include?(x.get_column('Bm #')) && skipped_skus.include?(x.get_column('So #')))
              skipped_skus.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
            end
          end
        end
      end
      puts 'SKIPPED SKUs', skipped_skus
    end

    fetch_csv('bible_sales_orders_total_mismatch.csv', csv_data)
  end

  def missing_sap_purchase_orders
    column_headers = ['inquiry', 'po_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_po.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        purchase_order = PurchaseOrder.find_by_po_number(x.get_column('#').to_i) || PurchaseOrder.find_by_old_po_number(x.get_column('#').to_i)
        if purchase_order.blank?
          writer << [x.get_column('Project'), x.get_column('#')]
        end
      end
    end

    fetch_csv('sap_missing_po.csv', csv_data)
  end

  def purchase_order_totals_mismatch
    column_headers = ['PO_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax', 'is_legacy']
    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_po.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        purchase_order = PurchaseOrder.find_by_po_number(x.get_column('#')) || PurchaseOrder.find_by_old_po_number(x.get_column('#'))
        if purchase_order.present? &&
            ((purchase_order.calculated_total_with_tax.to_f != x.get_column('Document Total').to_f) || (purchase_order.calculated_total.to_f != (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f).to_f)) &&
            ((purchase_order.calculated_total_with_tax.to_f - x.get_column('Document Total').to_f).abs > 1 || (purchase_order.calculated_total.to_f - (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f).to_f).abs > 1)
          writer << [purchase_order.po_number, purchase_order.calculated_total.to_f, purchase_order.calculated_total_with_tax.to_f, (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f), x.get_column('Document Total').to_f, purchase_order.is_legacy?]
        end
        # if !purchase_order.present?
        #   writer << [x.get_column('Po number'), x.get_column('Date'), x.get_column('Project'), x.get_column('Document Total'), x.get_column('Project Code'),x.get_column('Tax Amount (SC)'),x.get_column('Canceled')]
        # end
      end
    end

    fetch_csv('purchase_orders_total_mismatch.csv', csv_data)
  end

  def missing_sap_invoices
    column_headers = ['invoice_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_invoices.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#')) || SalesInvoice.find_by_old_invoice_number(x.get_column('#'))
        if sales_invoice.blank?
          writer << [x.get_column('#')]
        end
      end
    end

    fetch_csv('sap_missing_invoices.csv', csv_data)
  end

  def sap_sales_invoice_totals_mismatch
    column_headers = ['invoice_number', 'sprint_total', 'sprint_tax', 'sprint_total_with_tax', 'sap_total', 'sap_tax', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_invoices.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#'))
        sap_total_without_tax = 0
        total_without_tax = 0

        if sales_invoice.present? && !sales_invoice.is_legacy?
          total_without_tax = sales_invoice.metadata['base_grand_total'].to_f - sales_invoice.metadata['base_tax_amount'].to_f
          sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f
          if (total_without_tax != sap_total_without_tax) || (sales_invoice.metadata['base_grand_total'].to_f != x.get_column('Document Total').to_f) &&
              ((total_without_tax - sap_total_without_tax).abs > 1 || (sales_invoice.metadata['base_grand_total'].to_f - x.get_column('Document Total').to_f).abs > 1)

            writer << [
                sales_invoice.invoice_number,
                total_without_tax,
                sales_invoice.metadata['base_tax_amount'].to_f,
                sales_invoice.metadata['base_grand_total'].to_f,
                sap_total_without_tax,
                x.get_column('Tax Amount (SC)').to_f,
                x.get_column('Document Total')
            ]
          end
        end
      end
    end

    fetch_csv('sap_invoices_totals_mismatch.csv', csv_data)
  end

  # 8888888881
  # SalesOrder.where('order_number > ? AND order_number < ?', 1, 100).second_to_last.order_number

  # main
  def complete_bible_orders_mismatch_with_dates
    column_headers = ['inquiry_number', 'client order date', 'order_number', 'old_order_number', 'order date', 'SKU', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax', 'kit order', 'adjustment entry']
    matching_orders = []
    repeating_skus = []
    missing_skus = []
    missing_orders = []
    matching_rows_total = 0
    matching_bible_rows = 0
    repeating_matching_bible_rows = 0
    repeating_matching_rows_total = 0

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        is_adjustment_entry = 'No'
        order_number = x.get_column('So #')
        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        if bible_order_row_total.negative?
          sales_order = SalesOrder.where("metadata->>'credit_note_entry_for_order' = ?", order_number).first
        elsif order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          sales_order = SalesOrder.find_by_old_order_number(order_number)
        else
          sales_order = SalesOrder.find_by_order_number(order_number.to_i)
        end

        if sales_order.present?
          product_sku = x.get_column('Bm #').to_s.upcase

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price.to_f.round(2)
            row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)

            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)

              # adjustment entries
              if (row_total == -(bible_order_row_total)) || (row_total_with_tax == -(bible_order_row_total_with_tax)) || bible_order_row_total_with_tax.negative? || bible_order_row_total.negative?
                is_adjustment_entry = 'Yes'
              end

              # KIT check
              if sales_order.calculated_total.to_f.round(2) == bible_order_row_total &&
                  sales_order.calculated_total_with_tax.to_f.round(2) == bible_order_row_total_with_tax
                writer << [x.get_column('Inquiry Number'), x.get_column('Client Order Date'), sales_order.order_number, sales_order.old_order_number || 'nil', x.get_column('Order Date'), product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, 'Yes', is_adjustment_entry]
              else
                writer << [x.get_column('Inquiry Number'), x.get_column('Client Order Date'), sales_order.order_number, sales_order.old_order_number || 'nil', x.get_column('Order Date'), product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, 'No', is_adjustment_entry]
              end
            else
              if matching_orders.include?(x.get_column('Bm #') + '-' + x.get_column('So #'))
                repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
                repeating_matching_rows_total = repeating_matching_rows_total + row_total_with_tax
                repeating_skus.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              else
                matching_bible_rows = matching_bible_rows + bible_order_row_total_with_tax
                matching_rows_total = matching_rows_total + row_total_with_tax
                matching_orders.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              end
            end
          else
            missing_skus.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
          end
        else
          missing_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
        end
      end
      puts 'Matching orders uniq', matching_orders.uniq.count
      puts 'Matching orders', matching_orders.count
      puts 'Totals(Bible, sprint)', matching_bible_rows.to_f, matching_rows_total.to_f
      puts 'REPEATING SKUS', repeating_skus
      puts 'MISSING SKUs', missing_skus, missing_skus.count
      puts 'MISSING ORDERS', missing_orders, missing_orders.count
      puts 'TOTALS FOR REPEATING SKUS(BIBLE/Sprint)', repeating_matching_bible_rows, repeating_matching_rows_total
    end

    fetch_csv('fresh_bible_mismatch_first_run30.csv', csv_data)
  end

  def complete_mismatch_sheet
    column_headers = ['Inside Sales Name',	'Client Order Date',	'Price Currency',	'Document Rate',	'Magento Company Name',	'Company Alias',	'Inquiry Number',	'So #',	'Order Date',	'Bm #',	'Description',	'Order Qty',	'Unit Selling Price',	'Freight',	'Tax Type',	'Tax Rate',	'Tax Amount',	'Total Selling Price',	'Total Landed Cost',	'Unit cost price',	'Margin',	'Margin (In %)',	'Kit',	'AE', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']
    matching_orders = []
    repeating_skus = []
    missing_skus = []
    missing_orders = []
    multiple_not_booked_orders = []
    matching_rows_total = 0
    matching_bible_rows = 0

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        is_adjustment_entry = 'No'
        order_number = x.get_column('So #')
        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        if bible_order_row_total.negative?
          sales_order = SalesOrder.where(parent_id: order_number, is_credit_note_entry: true).first
        elsif order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          if order_number == 'Not Booked'
            inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders
            if inquiry_orders.count > 1
              multiple_not_booked_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
            else
              sales_order = inquiry_orders.first if inquiry_orders.first.old_order_number == 'Not Booked'
            end
          else
            sales_order = SalesOrder.find_by_old_order_number(order_number)
          end
        else
          sales_order = SalesOrder.find_by_order_number(order_number.to_i)
        end

        if sales_order.present?
          product_sku = x.get_column('Bm #').to_s.upcase

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price.to_f.round(2)
            row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)

            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)

              # adjustment entries
              if (row_total == -(bible_order_row_total)) || (row_total_with_tax == -(bible_order_row_total_with_tax)) || bible_order_row_total_with_tax.negative? || bible_order_row_total.negative?
                is_adjustment_entry = 'Yes'
              end

              # KIT check
              if sales_order.calculated_total.to_f.round(2) == bible_order_row_total &&
                  sales_order.calculated_total_with_tax.to_f.round(2) == bible_order_row_total_with_tax
                writer << [x.get_column('Inside Sales Name'),
                           x.get_column('Client Order Date'),
                           x.get_column('Price Currency'),
                           x.get_column('Document Rate'),
                           x.get_column('Magento Company Name').gsub(';',' '),
                           x.get_column('Company Alias').gsub(';',' '),
                           x.get_column('Inquiry Number'),
                           x.get_column('So #'),
                           x.get_column('Order Date'),
                           x.get_column('Bm #'),
                           x.get_column('Description').gsub(';',' '),
                           x.get_column('Order Qty'),
                           x.get_column('Unit Selling Price'),
                           x.get_column('Freight'),
                           x.get_column('Tax Type'),
                           x.get_column('Tax Rate'),
                           x.get_column('Tax Amount'),
                           x.get_column('Total Selling Price'),
                           x.get_column('Total Landed Cost'),
                           x.get_column('Unit cost price'),
                           x.get_column('Margin'),
                           x.get_column('Margin (In %)'), 'Yes', is_adjustment_entry,
                           row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax]
              else
                writer << [x.get_column('Inside Sales Name'),
                           x.get_column('Client Order Date'),
                           x.get_column('Price Currency'),
                           x.get_column('Document Rate'),
                           x.get_column('Magento Company Name').gsub(';',' '),
                           x.get_column('Company Alias').gsub(';',' '),
                           x.get_column('Inquiry Number'),
                           x.get_column('So #'),
                           x.get_column('Order Date'),
                           x.get_column('Bm #'),
                           x.get_column('Description').gsub(';',' '),
                           x.get_column('Order Qty'),
                           x.get_column('Unit Selling Price'),
                           x.get_column('Freight'),
                           x.get_column('Tax Type'),
                           x.get_column('Tax Rate'),
                           x.get_column('Tax Amount'),
                           x.get_column('Total Selling Price'),
                           x.get_column('Total Landed Cost'),
                           x.get_column('Unit cost price'),
                           x.get_column('Margin'),
                           x.get_column('Margin (In %)'), 'No', is_adjustment_entry,
                           row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax]
              end
            else
              if matching_orders.include?(x.get_column('Bm #') + '-' + x.get_column('So #'))
                repeating_skus.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              else
                matching_bible_rows = matching_bible_rows + bible_order_row_total_with_tax
                matching_rows_total = matching_rows_total + row_total_with_tax
                matching_orders.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              end
            end
          else
            missing_skus.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
          end
        else
          missing_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
        end
      end
      puts 'Matching orders uniq', matching_orders.uniq.count
      puts 'Matching orders', matching_orders.count
      puts 'Totals(Bible, sprint)', matching_bible_rows.to_f, matching_rows_total.to_f
      puts 'REPEATING SKUS', repeating_skus
      puts 'MISSING SKUs', missing_skus, missing_skus.count
      puts 'MISSING ORDERS', missing_orders, missing_orders.count
      puts 'MULTIPLE NOT BOOKED ORDERS', multiple_not_booked_orders, multiple_not_booked_orders.count
    end

    fetch_csv('bible_mismatch_initial_run.csv', csv_data)
  end

  def update_non_kit_non_ae_negative_mismatch
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    has_vat = []
    neg_entry = []
    not_uc_list = []
    repeating_rows = []
    repeating_matching_bible_rows = 0
    repeating_matching_rows_total = 0
    not_uc_list_total = 0
    not_uc_bible_total = 0

    updated_orders_with_matching_total_with_tax = []
    updated_orders_total_with_tax = 0
    bible_total_with_tax = 0

    updated_orders_with_matching_total = []
    updated_orders_total = 0
    bible_total = 0

    i = 0
    j = 0
    iteration = 1

    non_kit_non_ae_negative_mismatch = ['BM0C7B2-200046', 'BM0J2N5-200046', 'BM1A6Q7-200056', 'BM0I0R4-200105', 'BM0C7K0-200120', 'BM0C8Y9-200128', 'BM9B3N8-200151', 'BM0C7B2-200162', 'BM0L8R8-200167', 'BM0L8R9-200167', 'BM1B0W4-200169', 'BM1B0W5-200169', 'BM1B0W6-200169', 'BM0C7P6-200187', 'BM0C7Q5-200188', 'BM0O4A9-200196', 'BM0C7C6-200199', 'BM0C7F5-200199', 'BM0C7R0-200199', 'BM0C8G9-200199', 'BM0C8T7-200199', 'BM0C9D6-200199', 'BM0C9D7-200199', 'BM0C9D8-200199', 'BM0C9D9-200199', 'BM0L8M4-200199', 'BM0Z1D0-200199', 'BM0Z1D2-200199', 'BM1A5Z3-200199', 'BM1A5Z4-200199', 'BM1A6O4-200199', 'BM1A6O5-200199', 'BM1A6O6-200199', 'BM1A8B5-200199', 'BM1A8B6-200199', 'BM1A8B7-200199', 'BM1A5Z0-200202', 'BM1A5Z1-200202', 'BM1A6Q6-200202', 'BM1A6Q7-200202', 'BM1A6Q8-200202', 'BM1A6Q9-200202', 'BM1A6R0-200202', 'BM1A6R1-200202', 'BM1A6R2-200202', 'BM1A6R3-200202', 'BM1A6R4-200202', 'BM1A6R5-200202', 'BM1A6R6-200202', 'BM1A6R7-200202', 'BM1A6R9-200202', 'BM1A6S0-200202', 'BM1A6S1-200202', 'BM1A6S2-200202', 'BM1A6S3-200202', 'BM1A6S4-200202', 'BM1A6S5-200202', 'BM1A6S6-200202', 'BM1A6S7-200202', 'BM1A6S8-200202', 'BM1A6S9-200202', 'BM1A6T0-200202', 'BM1A6T1-200202', 'BM1A6T3-200202', 'BM1A6T4-200202', 'BM1A6T5-200202', 'BM1A6T6-200202', 'BM1A6T7-200202', 'BM1A6T8-200202', 'BM1A6T9-200202', 'BM1A6U0-200202', 'BM1A6U1-200202', 'BM1A6U2-200202', 'BM1A6U3-200202', 'BM1A6U4-200202', 'BM1A6U5-200202', 'BM1A6U6-200202', 'BM1A6U7-200202', 'BM1A6U8-200202', 'BM1A6U9-200202', 'BM1A6V0-200202', 'BM1A6V1-200202', 'BM1A6V2-200202', 'BM1A6V3-200202', 'BM1A6V5-200202', 'BM1A6V7-200202', 'BM1A6V8-200202', 'BM1A6V9-200202', 'BM1A6W0-200202', 'BM1A6W1-200202', 'BM1A6W2-200202', 'BM1A6W3-200202', 'BM1A6W4-200202', 'BM1A6W5-200202', 'BM1A6W6-200202', 'BM1A6W7-200202', 'BM1A6W8-200202', 'BM1A6W9-200202', 'BM1A6X0-200202', 'BM1A6X1-200202', 'BM1A6X2-200202', 'BM1A6X3-200202', 'BM1A6X4-200202', 'BM1A6X5-200202', 'BM1A6X6-200202', 'BM1A6X7-200202', 'BM1A6X8-200202', 'BM1A6Y0-200202', 'BM1A6Y1-200202', 'BM1A6Y2-200202', 'BM1A6Y3-200202', 'BM1A6Y4-200202', 'BM1A6Y5-200202', 'BM1A6Y6-200202', 'BM1A6Y7-200202', 'BM1A6Z0-200202', 'BM1A6Z1-200202', 'BM1A6Z2-200202', 'BM1A6Z3-200202', 'BM1A6Z4-200202', 'BM1A6Z5-200202', 'BM1A6Z6-200202', 'BM1A6Z7-200202', 'BM1A6Z8-200202', 'BM1A6Z9-200202', 'BM1A7A0-200202', 'BM1A7A1-200202', 'BM1A7A2-200202', 'BM1A7A3-200202', 'BM0C7A6-200208', 'BM0C7B2-200208', 'BM0C7C1-200208', 'BM0C7C6-200208', 'BM0C7D5-200208', 'BM0C7F4-200208', 'BM0C7G2-200208', 'BM0C7G4-200208', 'BM0C7H9-200208', 'BM0C7I4-200208', 'BM0C7I9-200208', 'BM0C7J0-200208', 'BM0C7J1-200208', 'BM0C7M1-200208', 'BM0C7O7-200208', 'BM0C7P6-200208', 'BM0C7Q6-200208', 'BM0C7Q8-200208', 'BM0C7R1-200208', 'BM0C7R2-200208', 'BM0C7R3-200208', 'BM0C7R4-200208', 'BM0C7R5-200208', 'BM0C7R6-200208', 'BM0C7R7-200208', 'BM0C7R8-200208', 'BM0C7R9-200208', 'BM0C7S0-200208', 'BM0C7S1-200208', 'BM0C7S2-200208', 'BM0C7T6-200208', 'BM0C7T8-200208', 'BM0C7V0-200208', 'BM0C7X6-200208', 'BM0C8E9-200208', 'BM0C8F1-200208', 'BM0C8G8-200208', 'BM0C8H2-200208', 'BM0C8T9-200208', 'BM0C8W6-200208', 'BM0C8Z1-200208', 'BM0C9A8-200208', 'BM0C9A9-200208', 'BM0C9B1-200208', 'BM0C9B3-200208', 'BM0C9B4-200208', 'BM0C9B8-200208', 'BM0C9B9-200208', 'BM0C9C1-200208', 'BM0C9D0-200208', 'BM0C9E2-200208', 'BM0C9E5-200208', 'BM0C9E6-200208', 'BM0C9E7-200208', 'BM0C9F9-200208', 'BM0C9I8-200208', 'BM0C9M8-200208', 'BM0L8L7-200208', 'BM1A4B3-200208', 'BM1A6A0-200208', 'BM1A6A3-200208', 'BM1A6D6-200208', 'BM1A6M9-200208', 'BM1A6N6-200208', 'BM1A7H7-200208', 'BM1A7I4-200208', 'BM1A7J9-200208', 'BM1A7K5-200208', 'BM1A7N6-200208', 'BM1A7N8-200208', 'BM1A7Q8-200208', 'BM1A7W3-200208', 'BM1A7W4-200208', 'BM1A7W5-200208', 'BM1A7W6-200208', 'BM1A7W8-200208', 'BM1A7X1-200208', 'BM1A7X2-200208', 'BM1A7X3-200208', 'BM1A7X4-200208', 'BM1A7X5-200208', 'BM1A7X6-200208', 'BM1A7X7-200208', 'BM1A7X8-200208', 'BM1A7X9-200208', 'BM1A7Y2-200208', 'BM1A7Y3-200208', 'BM1A7Y4-200208', 'BM1A7Y5-200208', 'BM1A7Y6-200208', 'BM1A7Y7-200208', 'BM1A7Y8-200208', 'BM1A7Y9-200208', 'BM1A7Z0-200208', 'BM1A7Z1-200208', 'BM1A7Z2-200208', 'BM1A7Z3-200208', 'BM1A7Z4-200208', 'BM1A7Z5-200208', 'BM1A7Z6-200208', 'BM1A7Z7-200208', 'BM1A7Z8-200208', 'BM1A7Z9-200208', 'BM1A8A0-200208', 'BM1A8A1-200208', 'BM1A8A2-200208', 'BM1A8A3-200208', 'BM1A8A4-200208', 'BM1A8B2-200208', 'BM1A8B3-200208', 'BM1A8D9-200208', 'BM1A8E0-200208', 'BM1A8E1-200208', 'BM1A8E2-200208', 'BM1A8E3-200208', 'BM1A8E4-200208', 'BM1A8E5-200208', 'BM1A8E6-200208', 'BM1A8E7-200208', 'BM1A8E8-200208', 'BM1A8G4-200208', 'BM1A8G5-200208', 'BM1A8G6-200208', 'BM1A8G7-200208', 'BM1A8G8-200208', 'BM0C7G2-200210', 'BM0C7N8-200210', 'BM0C7T2-200210', 'BM0C8L7-200210', 'BM0C8L8-200210', 'BM0C8U4-200210', 'BM0C8U7-200210', 'BM0C8U8-200210', 'BM0C8U9-200210', 'BM0C8V0-200210', 'BM0C8V1-200210', 'BM0C8X3-200210', 'BM0C8X4-200210', 'BM0C8X5-200210', 'BM0C8X8-200210', 'BM0C9G5-200210', 'BM1A8V8-200212', 'BM1A8V9-200212', 'BM1A8W0-200212', 'BM1A8W1-200212', 'BM1A8W2-200212', 'BM1A8W3-200212', 'BM1A8W4-200212', 'BM1A8W5-200212', 'BM1A8W6-200212', 'BM1A8W7-200212', 'BM1A8W8-200212', 'BM1A8W9-200212', 'BM0C7A0-200213', 'BM0C7B0-200213', 'BM0C7B1-200213', 'BM0C7B2-200213', 'BM0C7B8-200213', 'BM0C7C9-200213', 'BM0C7D8-200213', 'BM0C7F5-200213', 'BM0C7F7-200213', 'BM0C7F8-200213', 'BM0C7G1-200213', 'BM0C7G7-200213', 'BM0C7I4-200213', 'BM0C7T5-200213', 'BM0C7U2-200213', 'BM0C7V4-200213', 'BM0C8G8-200213', 'BM0C8H6-200213', 'BM0C8S9-200213', 'BM0C8T7-200213', 'BM0C8U4-200213', 'BM0C8Y8-200213', 'BM0C9F8-200213', 'BM0C9G0-200213', 'BM0C9G1-200213', 'BM1A7Z0-200213', 'BM1A8K9-200213', 'BM1A8L0-200213', 'BM1A8L1-200213', 'BM1A8L3-200213', 'BM1A8L4-200213', 'BM1A8L5-200213', 'BM1A8L6-200213', 'BM1A8L7-200213', 'BM1A8F0-200226', 'BM1A8F1-200226', 'BM0Z1F5-200234', 'BM1A4U6-200237', 'BM0C8U4-200256', 'BM1A3O0-200256', 'BM1A3O1-200256', 'BM1A3O3-200256', 'BM1A3O7-200256', 'BM1A3O8-200256', 'BM1A3O9-200256', 'BM1A3P0-200256', 'BM1A3P1-200256', 'BM1A3P2-200256', 'BM1A3P4-200256', 'BM1A3P5-200256', 'BM1A3P6-200256', 'BM1A3P7-200256', 'BM1A3Q2-200256', 'BM1A3Q3-200256', 'BM1A8I0-200260', 'BM9A2Y4-200318', 'BM0Z0M7-200582', 'BM9C3Z9-200591', 'BM9C4A1-200591', 'BM9B6X2-200599', 'BM1G0Q7-200639', 'BM1G0Q8-200639', 'BM9C4W8-200726', 'BM9C4W9-200726', 'BM9C4X1-200726', 'BM0O4O6-200769', 'BM0O4O7-200769', 'BM0O4P1-200769', 'BM0O4P3-200769', 'BM0O4Q3-200769', 'BM0O4Q4-200769', 'BM0O4Q5-200769', 'BM0O4S6-200769', 'BM0O4T1-200769', 'BM0O4T3-200769', 'BM0O4T7-200769', 'BM9A4E4-200769', 'BM0O3Y7-200770', 'BM0O4E4-200770', 'BM0O4E6-200770', 'BM0O4E7-200770', 'BM0O4F1-200770', 'BM0O4F3-200770', 'BM0O4F4-200770', 'BM0O4F7-200770', 'BM0O4F9-200770', 'BM0O4G8-200770', 'BM0O4G9-200770', 'BM0O4H6-200770', 'BM0O4I5-200770', 'BM0O4I7-200770', 'BM0O4J5-200770', 'BM0O4J6-200770', 'BM0O4J7-200770', 'BM0O4J8-200770', 'BM0O4K0-200770', 'BM0O4K1-200770', 'BM0O4K2-200770', 'BM0O4K6-200770', 'BM0O4L8-200770', 'BM0O4M0-200770', 'BM0O4M1-200770', 'BM0O4V1-200770', 'BM9A3R1-200770', 'BM9A3R2-200770', 'BM9A4Y2-200770', 'BM0O4V2-200818', 'BM0O4V4-200818', 'BM9C7W1-200852', 'BM9C8D8-200914', 'BM9C8D9-200914', 'BM1A4X2-200942', 'BM9A5Y9-200956', 'BM1G0Q7-200973', 'BM1G0Q7-200974', 'BM9C8Y1-200982', 'BM1G0Q6-200991', 'BM9A7P6-201050', 'BM9A7P7-201050', 'BM9A7P8-201050', 'BM9B7J7-201065', 'BM9D2N1-201147', 'BM9D2N2-201147', 'BM9A8T4-201201', 'BM9D5V6-201204', 'BM9D5W1-201204', 'BM9D5W2-201204', 'BM9D5W3-201204', 'BM9D5W4-201204', 'BM9D6N6-201204', 'BM9D6V5-201205', 'BM9D6V6-201205', 'BM9D6V7-201219', 'BM9D6Z7-201235', 'BM9D8X2-201306', 'BM9D8X3-201306', 'BM9D8X4-201306', 'BM9D8X5-201306', 'BM9D8X6-201306', 'BM9D8X7-201306', 'BM9D8X8-201306', 'BM9D8X9-201306', 'BM9D8Y1-201306', 'BM9D8Y2-201306', 'BM9D8Y3-201306', 'BM9D8Y4-201306', 'BM9D8Y5-201306', 'BM9D8Y6-201306', 'BM9D8Y7-201306', 'BM9D8Y8-201306', 'BM9D8V4-201321', 'BM9E2S4-201484', 'BM9E1L9-201494', 'BM9E3G3-201503', 'BM9E2T2-201516', 'BM9E2T3-201516', 'BM0K9A4-201601', 'BM9D8A3-201615', 'BM9C8Y1-201631', 'BM9D9Q3-201705', 'BM1B2L6-201751', 'BM9E9C8-201806', 'BM9E9C9-201806', 'BM9E3G4-201807', 'BM9E8T5-201828', 'BM9E8T6-201828', 'BM9E8T7-201828', 'BM9E8T8-201828', 'BM9E8T9-201828', 'BM9E8U1-201828', 'BM9E8U2-201828', 'BM9E8U3-201828', 'BM9E8U4-201828', 'BM9E8U5-201828', 'BM9E8U6-201828', 'BM9E8U7-201828', 'BM9E8U8-201828', 'BM9E8V1-201828', 'BM9E8V2-201828', 'BM9E8V4-201828', 'BM9E8V5-201828', 'BM9E8V6-201828', 'BM9E8V8-201828', 'BM9E8V9-201828', 'BM9E8W1-201828', 'BM9F4C9-201877', 'BM9F4C7-201889', 'BM9E1Y3-201931', 'BM9F6T4-201949', 'BM9F6T5-201949', 'BM9F6T6-201949', 'BM9F6T7-201949', 'BM9F6T8-201949', 'BM9F6T9-201949', 'BM9F6U1-201949', 'BM9F6U2-201949', 'BM9F6U3-201949', 'BM9F6U4-201949', 'BM9F6U5-201949', 'BM1A0E4-201996', 'BM9F5E1-202007', 'BM9F9U9-202010', 'BM9E5S4-202048', 'BM9E8P5-202083', 'BM0Y8Z1-202085', 'BM9D3Y1-202090', 'BM9D3Y2-202090', 'BM9D3Y3-202090', 'BM9D3Y4-202090', 'BM9D3Y5-202090', 'BM9D3Y7-202090', 'BM9D3Y8-202090', 'BM9D3Y9-202090', 'BM9D3Z1-202090', 'BM9F9C8-2000047', 'BM9E8C4-2000099', 'BM9E8C5-2000099', 'BM9E8C6-2000099', 'BM9G5B7-2000127', 'BM0C9A0-2000165', 'BM0K9O8-2000166', 'BM0C7B3-2000167', 'BM0C7F6-2000197', 'BM0C7F5-2000199', 'BM0C7F6-2000200', 'BM0C7F6-2000202', 'BM0K9O8-2000204', 'BM0C7F6-2000205', 'BM0C7F5-2000206', 'BM0C7F5-2000207', 'BM0C7F5-2000208', 'BM0C7I4-2000209', 'BM0C7F5-2000210', 'BM0C7F5-2000211', 'BM0C7B3-2000213', 'BM0C7A1-2000214', 'BM0C7I4-2000216', 'BM0C7F8-2000217', 'BM0C7B3-2000218', 'BM1G0M3-2000219', 'BM1G0M3-2000220', 'BM0C7B3-2000221', 'BM0K9O8-2000222', 'BM0C7C7-2000223', 'BM0C7F6-2000224', 'BM1G0M3-2000226', 'BM0C7F6-2000227', 'BM0C7B3-2000228', 'BM0C7B3-2000233', 'BM0Q8Y4-2000234', 'BM0C8I0-2000235', 'BM0C9A0-2000237', 'BM1G0F0-2000238', 'BM0C7U2-2000239', 'BM0C7B3-2000240', 'BM0C7B3-2000242', 'BM0C7U2-2000243', 'BM0C7B3-2000244', 'BM0C7A0-2000247', 'BM9F5H1-2000255', 'BM0C7F8-2000256', 'BM0C7V0-2000258', 'BM9F5H1-2000259', 'BM0O6H8-2000260', 'BM0C7Q0-2000263', 'BM0C7B3-2000264', 'BM0O6H8-2000265', 'BM0C7D3-2000266', 'BM1G0E9-2000267', 'BM9G8S6-2000272', 'BM9G5N4-2000300', 'BM9G5N5-2000300', 'BM9G5N6-2000300', 'BM9G5N7-2000300', 'BM9G5N8-2000300', 'BM1G0F0-2000322', 'BM0H8A4-2000328', 'BM0C7D5-2000348', 'BM0C7I3-2000348', 'BM9G3W2-2000355', 'BM9G3W3-2000355', 'BM9G3W4-2000355', 'BM9G3W5-2000355', 'BM0Q8Y4-2000359', 'BM0O6H8-2000360', 'BM0C9A0-2000361', 'BM0C7U5-2000362', 'BM1G0E9-2000364', 'BM0C9A0-2000371', 'BM0C8I0-2000372', 'BM0C7P6-2000374', 'BM0O6H8-2000376', 'BM0C7B3-2000377', 'BM0C7B3-2000378', 'BM0C7V1-2000382', 'BM0C7Q0-2000389', 'BM9E4Z6-2000422', 'BM9E4Z7-2000422', 'BM9E4Z8-2000422', 'BM9E4Z9-2000422', 'BM9E5A1-2000422', 'BM9E5A2-2000422', 'BM0K9O8-2000451', 'BM9A6Z6-2000454', 'BM0C7U5-2000455', 'BM0C7V1-2000466', 'BM0C7G2-2000467', 'BM0Q8Y4-2000468', 'BM0O6H8-2000469', 'BM9G8G5-2000470', 'BM0C7I3-2000471', 'BM0C7U8-2000480', 'BM0C7U9-2000481', 'BM0C7U5-2000482', 'BM9H3P1-2000489', 'BM9H3P2-2000489', 'BM9H3P3-2000489', 'BM9H3P4-2000489', 'BM9F3F3-2000493', 'BM0C7B3-2000495', 'BM0O6H8-2000497', 'BM0C7H1-2000520', 'BM0C7V1-2000521', 'BM0C7G1-2000522', 'BM0C7B3-2000524', 'BM0C7B3-2000527', 'BM0C7B3-2000528', 'BM0C7A1-2000530', 'BM4K3W1-2000532', 'BM4K3W1-2000533', 'BM4K3W1-2000534', 'BM0C7B3-2000584', 'BM0Q8Y4-2000585', 'BM0C7V1-2000587', 'BM0C7B3-2000588', 'BM0Q8Y4-2000589', 'BM0C7B3-2000597', 'BM4K3W1-2000599', 'BM0C7B3-2000604', 'BM9G9U7-2000611', 'BM9G9U8-2000611', 'BM0C7B3-2000614', 'BM0C7U9-2000616', 'BM0C7Q0-2000623', 'BM0Q8X8-2000624', 'BM4K3W1-2000625', 'BM0O6H8-2000654', 'BM0C7B3-2000664', 'BM0C7I3-2000665', 'BM0C7B3-2000666', 'BM3U7A3-2000667', 'BM0C7B3-2000668', 'BM4K3W1-2000671', 'BM0C7B3-2000673', 'BM0C7B3-2000674', 'BM0C6Z9-2000676', 'BM0C6Z9-2000677', 'BM0C7B3-2000679', 'BM0C7P6-2000682', 'BM0C7P6-2000683', 'BM0C7P6-2000684', 'BM0C7B3-2000685', 'BM0C7B3-2000696', 'BM0C7B3-2000698', 'BM0C7B3-2000701', 'BM9H9C3-2000702', 'BM9H9C4-2000702', 'BM9K1B2-2001676', 'BM9K1B4-2001676', 'BM9K6Q2-2001940', 'BM9G3J3-2002215', 'BM9G3J8-2002215', 'BM1G0F0-2002230', 'BM9J8H5-2002571', 'BM9K2R8-2002572', 'BM1B0F3-2002944', 'BM9G4S3-2002944', 'BM9M1X9-2003105', 'BM4H8M5-2003426', 'BM9D3R7-2003561', 'BM9N7J5-10200216', 'BM1A8J3-10210027', 'BM9M8U6-10210027', 'BM9M8U7-10210027', 'BM9M8U9-10210027', 'BM9M8V1-10210027', 'BM9M8V2-10210027', 'BM9M8V3-10210027', 'BM9M8V4-10210027', 'BME3Y1M-10210027', 'BM9L7R3-10210074', 'BM9L7S2-10210074', 'BM9L7S4-10210074', 'BM9P2Y7-10210125', 'BM9L6D8-10210128', 'BM9N9T3-10210161', 'BM9N9X2-10210161', 'BM9P2Y7-10210198', 'BM9P3Y4-10210294', 'BM9P3Y4-10210295', 'BM9Q8W4-10210301', 'BM9P3K4-10210316', 'BM9S5Q9-10210399', 'BM9P4U7-10210462', 'BM9P6M1-10210544', 'BM9P8D8-10210559', 'BM9Y8U9-10210559', 'BM9Q4U1-10210605', 'BM9R6B6-10210605', 'BM9T3G3-10210605', 'BM9T3V6-10210605', 'BM9W4E7-10210605', 'BM9X2P9-10210605', 'BM9Y7C7-10210605', 'BM9Z1P8-10210605', 'BM9S1G7-10210608', 'BM00008-10210645', 'BM9P7N1-10210690', 'BM9Q5P6-10210696', 'BM9W3S5-10210707', 'BM00008-10210709', 'BM9Y1Q7-10210766', 'BM9Z6F3-10210799', 'BM9S4G5-10210803', 'BM9S1G7-10210821', 'BM9P7M9-10210826', 'BM9M9Q3-10210831', 'BM9P4U7-10210846', 'BM9R1F9-10210891', 'BM9Z6F3-10210891', 'BM9W3S5-10210957', 'BM9R1F9-10210958', 'BM9S4G5-10210958', 'BM9Q1Z7-10210979', 'BM9Q2B8-10210981', 'BM9Q1T8-10211002', 'BM9Z6S4-10211021', 'BM9Z9T9-10211024', 'BM9U6V6-10211118', 'BM9Q3J6-10211131', 'BM9R1P5-10211132', 'BM9P5R9-10211235', 'BM9M9V9-10212228', 'BM3B8G1-10610052', 'BM9W9D7-10610052', 'BM9Y2T3-10610052', 'BM9Z7B2-10610052', 'BM9Z1X9-10610136', 'BM9E9F8-10610147', 'BM9P6J6-10610207', 'BM9P2X7-10610255', 'BM3B8G1-10610389', 'BM9P4N7-10610509', 'BM9P5M7-10910022', 'BM9W6T1-10910022', 'BM9Y7A9-11210038', 'BM9M5D3-11410026', 'BM9F5U2-99999055', 'BM9A3P8-100000130', 'BM9A3P9-100000130', 'BM9A3Q1-100000130', 'BM9A3Q2-100000130', 'BM9A3Q3-100000130', 'BM9A3Q4-100000130', 'BM0C7K0-100000165', 'BM0C7D8-100000171', 'BM1A6Q7-100000179', 'BM0C7Q5-100000193', 'BM0L8L7-100000196', 'BM0C7P6-100000197', 'BM0C9I8-100000206', 'BM0C7Q5-100000210', 'BM1A3Z4-100000218', 'BM0C9I8-100000223', 'BM0C7I4-100000224', 'BM0C7V0-100000228', 'BM0C7I4-100000231', 'BM1A3U8-100000233', 'BM0C7I4-100000237', 'BM0C7F8-100000247', 'BM1A3V0-100000250', 'BM1A3V1-100000250', 'BM1A3V2-100000250', 'BM1A3V4-100000250', 'BM1A3V5-100000250', 'BM1A3V6-100000250', 'BM1A3V7-100000250', 'BM1A3V8-100000250', 'BM1A3V9-100000250', 'BM1A3W0-100000250', 'BM1A3W1-100000250', 'BM1A3W2-100000250', 'BM1A4X3-100000250', 'BM1A4S0-100000259', 'BM1A3Q4-100000271', 'BM0C7V1-100000278', 'BM1A3M9-100000283', 'BM1A8Y8-100000294', 'BM1A8Y9-100000294', 'BM1A8Z0-100000294', 'BM1A8Z1-100000294', 'BM1A8Z2-100000294', 'BM1A8Z3-100000294', 'BM1A8Z4-100000294', 'BM1A8Z5-100000294', 'BM1A8Z6-100000294', 'BM1A8Z7-100000294', 'BM1A8Z8-100000294', 'BM1A8Z9-100000294', 'BM1A9A0-100000294', 'BM1A3U7-100000319', 'BM1A8T4-100000328', 'BM1A8D2-100000353', 'BM1A7W2-100000363', 'BM9A3U7-100000388', 'BM9A3U8-100000388', 'BM9A3U9-100000388', 'BM9A3V1-100000388', 'BM9A3V2-100000388', 'BM9A3V3-100000388', 'BM9A3V4-100000388', 'BM9A3V5-100000388', 'BM9A3V6-100000388', 'BM9A3V7-100000388', 'BM9A3V8-100000388', 'BM9A3V9-100000388', 'BM9A3W1-100000388', 'BM9A3W2-100000388', 'BM9A3W3-100000388', 'BM9A3W4-100000388', 'BM9A3W5-100000388', 'BM9A3W6-100000388', 'BM9A3W7-100000388', 'BM9A3W8-100000388', 'BM9A3W9-100000388', 'BM9A3X1-100000388', 'BM9A3X2-100000388', 'BM9A3X3-100000388', 'BM9A3X4-100000388', 'BM9A3X5-100000388', 'BM9A3X6-100000388', 'BM9A3X7-100000388', 'BM9A3X8-100000388', 'BM9A3X9-100000388', 'BM9A3Y1-100000388', 'BM9A3Y2-100000388', 'BM9A3Y3-100000388', 'BM9A3Y4-100000388', 'BM9A3Y5-100000388', 'BM9A3Y6-100000388', 'BM9A3T4-100000390', 'BM9A3T5-100000390', 'BM1A7C3-100000398', 'BM1A7N2-100000400', 'BM1A6L3-100000403', 'BM1A6Q0-100000403', 'BM1A7N0-100000404', 'BM1A7J0-100000405', 'BM1A7P0-100000406', 'BM1A7N3-100000408', 'BM1A7T8-100000409', 'BM1A6M2-100000415', 'BM1A6M3-100000415', 'BM1A6L6-100000416', 'BM1A7G8-100000422', 'BM1A7O3-100000427', 'BM1A7O4-100000427', 'BM1A7O5-100000427', 'BM1A7O6-100000427', 'BM1A7O7-100000427', 'BM1A7O8-100000427', 'BM1A7O9-100000427', 'BM1A6H8-100000431', 'BM1A6O7-100000432', 'BM1A7K2-100000435', 'BM1A8M0-100000443', 'BM1A7H1-100000472', 'BM1A7P3-100000472', 'BM1A7I6-100000482', 'BM1A7H2-100000483', 'BM1A7H3-100000483', 'BM0O3Z8-100000491', 'BM1A6I7-100000493', 'BM1A6J2-100000498', 'BM1A6J3-100000498', 'BM1A6A7-100000500', 'BM1A6J7-100000506', 'BM1A6N3-100000506', 'BM1A4P5-100000510', 'BM1A6C0-100000513', 'BM1A6C1-100000513', 'BM1A6C2-100000513', 'BM1A7L6-100000570', 'BM1A4Q7-100000585', 'BM1A7S4-100000586', 'BM1A4P0-100000593', 'BM1A6V6-100000593', 'BM1A4Q9-100000598', 'BM1A7R3-100000599', 'BM1A7H6-100000604', 'BM1A6E4-100000608', 'BM1A6Q2-100000608', 'BM1A8P1-100000612', 'BM1A8P2-100000612', 'BM1A8P3-100000612', 'BM1A8P4-100000612', 'BM1A8P5-100000612', 'BM1A8O4-100000613', 'BM1A8O5-100000613', 'BM1A8O6-100000613', 'BM1A8O7-100000613', 'BM1A4Q6-100000622', 'BM1A3M4-100000623', 'BM1A3M5-100000623', 'BM1A3M6-100000623', 'BM1A8M3-100000623', 'BM1A7N0-100000625', 'BM1A7V7-100000629', 'BM1A7V8-100000629', 'BM1A7V9-100000629', 'BM1A7W0-100000629', 'BM1A7W1-100000629', 'BM1A6B1-100000630', 'BM1A8P2-100000630', 'BM1A8P3-100000630', 'BM1A5Z5-100000633', 'BM1A7N0-100000647', 'BM0C7U2-100000649', 'BM1A6C9-100000661', 'BM1E1E7-100000674', 'BM0C7F6-100000677', 'BM0C8Z1-100000678', 'BM0C7T2-100000680', 'BM0C9M8-100000702', 'BM0C9M8-100000706', 'BM0C7T2-100000709', 'BM0C9M8-100000710', 'BM0C9M8-100000711', 'BM1A9T2-100000742', 'BM0C7D8-100000768', 'BM1A6N2-100000786', 'BM1A6N4-100000786', 'BM0C9M8-100000787', 'BM1A6N5-100000790', 'BM1A7N0-100000791', 'BM1A5O3-100000803', 'BM1A7N0-100000809', 'BM1A7C9-100000810', 'BM1A7D0-100000810', 'BM1A7D1-100000810', 'BM1A7D2-100000810', 'BM1A7D3-100000810', 'BM1A7D4-100000810', 'BM1A7D5-100000810', 'BM1A7D6-100000810', 'BM1A7D7-100000810', 'BM1A7D8-100000810', 'BM1A7E1-100000810', 'BM1A7N0-100000812', 'BM1A7N0-100000814', 'BM1A5E2-100000829', 'BM1A5E3-100000829', 'BM1A5E4-100000829', 'BM1A5E5-100000829', 'BM1A5E6-100000829', 'BM1A5E7-100000829', 'BM1A5E8-100000829', 'BM1A5E9-100000829', 'BM1A5F0-100000829', 'BM1A5F1-100000829', 'BM1A8E9-100000835', 'BM1A8F2-100000839', 'BM1A8F3-100000839', 'BM1A8F4-100000839', 'BM1A8F5-100000839', 'BM1A8F6-100000839', 'BM1A6G1-100000841', 'BM1A6G2-100000841', 'BM1A6G3-100000841', 'BM1A6G4-100000841', 'BM1A6G5-100000841', 'BM1A6G6-100000841', 'BM1A8H4-100000842', 'BM1A8H5-100000842', 'BM1A8H6-100000842', 'BM1A8V6-100000858', 'BM1A8V7-100000858', 'BM0C7F5-100000860', 'BM1A6V1-100000861', 'BM1A9A4-100000873', 'BM1A9A5-100000873', 'BM1A9A6-100000873', 'BM1A9A7-100000873', 'BM0C7O6-100000875', 'BM0C7G1-100000876', 'BM0C7R0-100000876', 'BM0C7O6-100000877', 'BM9A4J5-100000879', 'BM9A4J6-100000879', 'BM9A4J7-100000879', 'BM9A4J8-100000879', 'BM9A4J9-100000879', 'BM9A4K1-100000879', 'BM9A4K2-100000879', 'BM9A4K3-100000879', 'BM9A4K4-100000879', 'BM0Z0Z8-100000894', 'BM1A6G2-100000895', 'BM1A6G3-100000895', 'BM1A6G4-100000895', 'BM0C7G0-100000897', 'BM0C8E6-100000897', 'BM1A3T5-100000897', 'BM1A3Z3-100000897', 'BM1A8L4-100000897', 'BM1B2L6-100000911', 'BM0C7C9-100000914', 'BM0C7C9-100000915', 'BM0C8Z1-100000916', 'BM0O7Z5-100000927', 'BM0C7C9-100000936', 'BM0C7C9-100000937', 'BM1A7M9-100000943', 'BM1A6M5-100000945', 'BM1A6A3-100000947', 'BM1A8J2-100000957', 'BM9A2Y4-100001134', 'BM0C7F6-100001147', 'BM9A7W5-100001152', 'BM0O4E2-100001406', 'BM1A8J0-100001408', 'BM1A8J1-100001408', 'BM1A6K4-100001411', 'BM1A6K5-100001411', 'BM1A6K6-100001411', 'BM1A6K9-100001411', 'BM1A6L4-100001411', 'BM1A6L5-100001411', 'BM1A6M7-100001411', 'BM1A6M8-100001411', 'BM1A6P6-100001415', 'BM1A6P7-100001415', 'BM1A6P8-100001415', 'BM9A2Y4-100000146-1', 'BM0C7B2-100000195-1', 'BM1A3Y3-100000221-2', 'BM1A3Y4-100000221-2', 'BM1A8C0-100000355-2', 'BM1A8C1-100000355-2', 'BM1A8C2-100000355-2', 'BM1A8C3-100000355-2', 'BM1A8C4-100000355-2', 'BM1A8C5-100000355-2', 'BM1A8C6-100000355-2', 'BM1A8C7-100000355-2', 'BM1A8C8-100000355-2', 'BM1A8C9-100000355-2', 'BM1A8D0-100000355-2', 'BM1A8J2-100000357-1', 'BM1A8J3-100000357-1', 'BM1A7U6-100000360-2', 'BM1A7U7-100000360-2', 'BM1A7U8-100000360-2', 'BM1A7U9-100000360-2', 'BM1A7V0-100000360-2', 'BM1A7V1-100000360-2', 'BM1A7V2-100000360-2', 'BM1A7V3-100000360-2', 'BM1A7V4-100000360-2', 'BM1A7V5-100000360-2', 'BM1A6K1-100000411-2', 'BM0L8K2-100000480-1', 'BM1A5T7-100000554-1', 'BM1A5T8-100000554-1', 'BM1A5T9-100000554-1', 'BM1A5U0-100000554-1', 'BM1B1L9-100000705-1', 'BM1A4W9-100000859-2', 'BM0Y9N4-100000926-1', 'BM0O3Y7-100000960-1', 'BM0O4F4-100000960-1', 'BM0O4F5-100000960-1', 'BM0O4G2-100000960-1', 'BM0O4G7-100000960-1', 'BM0O4G8-100000960-1', 'BM0O4G9-100000960-1', 'BM0O4I3-100000960-1', 'BM0O4J5-100000960-1', 'BM0O4J6-100000960-1', 'BM0O4J9-100000960-1', 'BM0O4K0-100000960-1', 'BM0O4K1-100000960-1', 'BM0O4K2-100000960-1', 'BM0O4K5-100000960-1', 'BM0O4L2-100000960-1', 'BM0O4L4-100000960-1', 'BM0O4O5-100000960-1', 'BM0O4O7-100000960-1', 'BM0O4Q3-100000960-1', 'BM0O4Q5-100000960-1', 'BM0O4R0-100000960-1', 'BM0O4R2-100000960-1', 'BM0O4R6-100000960-1', 'BM0O4S3-100000960-1', 'BM0O4S6-100000960-1', 'BM0O4T1-100000960-1', 'BM0O4T3-100000960-1', 'BM0O4T4-100000960-1', 'BM0O4T7-100000960-1', 'BM0O4T9-100000960-1', 'BM0O4U3-100000960-1', 'BM0O4U4-100000960-1', 'BM0O4U7-100000960-1', 'BM0O4V1-100000960-1', 'BM0O4V2-100000960-1', 'BM0O4V3-100000960-1', 'BM0O4V4-100000960-1', 'BM0Z1J7-100000960-1', 'BM9A6U9-100001114-1', 'BM0O4B2-100001175-1', 'BM0C8Z1-2000164-1', 'BM0C7T2-2000196-1', 'BM0C7B2-200046-1', 'BM0J2N5-200046-1', 'BM9B4Y8-200080-1', 'BM1Z9R4-200184-1', 'BM9B3P1-200275-2', 'BM9B6L7-200275-2', 'BM9B6L8-200275-2', 'BM9B6L9-200275-2', 'BM0L0A6-200305-1', 'BM9B9X1-200512-1', 'BM9B6X2-200589-1', 'BM9C4K2-200609-1', 'BM9C4K3-200609-1', 'BM9C4K4-200609-1', 'BM9C4K5-200609-1', 'BM9C4L7-200609-1', 'BM9C4L8-200609-1', 'BM1G1U3-200614-3', 'BM3C8L6-200614-3', 'BM9B4A5-200614-3', 'BM9B4A6-200614-3', 'BM9B4A7-200614-3', 'BM9B4A8-200614-3', 'BM9B4B2-200614-3', 'BM9B4B3-200614-3', 'BM9B4B4-200614-3', 'BM9B4B5-200614-3', 'BM9B4B8-200614-3', 'BM9B4B9-200614-3', 'BM9B4C2-200614-3', 'BM9B4C3-200614-3', 'BM9B4C4-200614-3', 'BM9B4C5-200614-3', 'BM9B4C6-200614-3', 'BM9B4C7-200614-3', 'BM9B4C8-200614-3', 'BM9B4R1-200614-3', 'BM9B4R2-200614-3', 'BM9B4X4-200614-3', 'BM9B4X5-200614-3', 'BM9C1B5-200614-3', 'BM9C1B6-200614-3', 'BM9C1B7-200614-3', 'BM9C1B8-200614-3', 'BM9C1B9-200614-3', 'BM9C1C1-200614-3', 'BM9C1C3-200614-3', 'BM9C5C1-200614-3', 'BME3X5J-200614-3', 'BM9C7W7-200947-1', 'BM9D4B6-201083-1', 'BM9D6S6-201256-1', 'BM9D5V7-201283-1', 'BM9D9V1-201385-1', 'BM9D9V2-201385-1', 'BM9D9V3-201385-1', 'BM9E2H4-201481-1', 'BM9E3W7-201515-3', 'BM9E5U8-201809-1', 'BM9F1H1-201819-3', 'BM9D6S6-201898-2', 'BM9D9V1-201907-2', 'BM9D9V2-201907-2', 'BM9D9V4-201907-2', 'BM9F6Y1-202002-1', 'BM9F6Y2-202002-1', 'BM9F6Y3-202002-1', 'BM9F6Y4-202002-1', 'BM9F9A7-202023-1', 'BM9G1T2-202052-3', 'BM0C6Z9-Order1', 'BM0C7B3-Order1', 'BM0C7D3-Order1', 'BM0C7F5-Order1', 'BM0C7F6-Order1', 'BM0C7G1-Order1', 'BM0C7Q4-Order1', 'BM0C7U2-Order1', 'BM0C8W6-Order1', 'BM0Q8U1-Order1', 'BM0Q8X7-Order1', 'BM4K4E7-Order1', 'BM9J8U1-Order1', 'BM0C6Z9-Order2', 'BM0C7B3-Order2', 'BM0C7D3-Order2', 'BM0C7F5-Order2', 'BM0C7F6-Order2', 'BM0C7F7-Order2', 'BM0C7G1-Order2', 'BM0C7P6-Order2', 'BM0C7Q2-Order2', 'BM0C7U2-Order2', 'BM0C8I0-Order2', 'BM0C8W6-Order2', 'BM0C8Y9-Order2', 'BM0C9M9-Order2', 'BM0Q6S3-Order2', 'BM0Q8U1-Order2', 'BM4K4E7-Order2', 'BM9J8U1-Order2', 'BM0C9E8-200208', 'BM1A8X2-200237', 'BM1B0H5-200256', 'BM9C4K1-200609-1']

    temporary_skip_list = ['BM0P0P2 - 200227', 'BM1A4X2 - 2001311', 'BM1A7S9 - 100000536', 'BM0Y9N6 - 10041', 'BM1B2L9 - 10094', 'BM9A5W9 - 10140', 'BM9C7Y1 - 10016', 'BM9C7Y1 - 10017', 'BM9C7Y1 - 10018', 'BM9C7Y1 - 10019']

    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      product_sku = x.get_column('Bm #').to_s.upcase

      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        sales_order = SalesOrder.find_by_old_order_number(order_number)
      else
        sales_order = SalesOrder.find_by_order_number(order_number.to_i)
      end
      if sales_order.present?
        current_order_row = product_sku + ' - ' + sales_order.order_number.to_s
        next if temporary_skip_list.include?(current_order_row) || x.get_column('Tax Rate').include?('#N/A')

        if non_kit_non_ae_negative_mismatch.include?(current_order_row)
          puts "ITERATION", iteration
          iteration = iteration + 1

          # CST/VAT
          # if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST'))
          #   has_vat.push(product_sku + '-' + order_number)
          # end
          # next if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST'))

          bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
          bible_order_tax_total = x.get_column('Tax Amount').to_f
          bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

          # AE
          if bible_order_row_total.negative? && bible_order_row_total_with_tax.negative?
            neg_entry.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
          end
          next if bible_order_row_total.negative? && bible_order_row_total_with_tax.negative?

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            quote_row = order_row.sales_quote_row
            tax_rate_percentage = x.get_column('Tax Rate').split('%')[0]
            tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first

            quote_row.quantity = x.get_column('Order Qty').to_f if quote_row.quantity == x.get_column('Order Qty').to_f
            quote_row.unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.converted_unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.margin_percentage = x.get_column('Margin (In %)').split('%')[0]
            quote_row.tax_rate = tax_rate || nil
            quote_row.tax_type = x.get_column('Tax Type') if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') ||  x.get_column('Tax Type').include?('Service'))
            quote_row.legacy_applicable_tax_percentage = tax_rate_percentage.to_d || nil
            quote_row.inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)

            quote_row.created_at = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d') # check
            quote_row.save(validate: false)
            puts '****************************** QUOTE ROW SAVED ****************************************'
            quote_row.sales_quote.save(validate: false)
            puts '****************************** QUOTE SAVED ****************************************'

            order_row.quantity = x.get_column('Order Qty').to_f
            order_row.tax_type = x.get_column('Tax Type') if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') ||  x.get_column('Tax Type').include?('Service'))
            sales_order.mis_date = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            order_row.created_at = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d') # check
            order_row.save(validate: false)
            puts '****************************** ORDER ROW SAVED ****************************************'
            sales_order.save(validate: false)
            puts '****************************** ORDER SAVED ****************************************'

            row_total = order_row.total_selling_price.to_f.round(2)
            row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)

            if (row_total == bible_order_row_total) && (row_total_with_tax == bible_order_row_total_with_tax)
              if updated_orders_with_matching_total_with_tax.include?(x.get_column('Bm #') + '-' + x.get_column('So #'))
                repeating_rows.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
                repeating_matching_rows_total = repeating_matching_rows_total + row_total_with_tax
                repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
              else
                i = i + 1
                puts 'Matched order count', i
                updated_orders_with_matching_total_with_tax.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
                updated_orders_total_with_tax = updated_orders_total_with_tax + row_total_with_tax
                bible_total_with_tax = bible_total_with_tax + bible_order_row_total_with_tax
              end

            elsif !((row_total == bible_order_row_total) && (row_total_with_tax == bible_order_row_total_with_tax))
              j = j + 1
              puts 'Mismatched order count', j
              updated_orders_with_matching_total.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              updated_orders_total = updated_orders_total + row_total_with_tax
              bible_total = bible_total + bible_order_row_total_with_tax

            else
              not_uc_list.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              not_uc_list_total = not_uc_list_total + row_total_with_tax
              not_uc_bible_total = not_uc_bible_total + bible_order_row_total_with_tax
            end
          else
            # add missing skus in sprint
          end
        end
      else
        # add missing orders in sprint
      end
    end
    puts 'HAS VAT', has_vat
    puts 'NEGATIVE ENTRIES', neg_entry
    puts 'NEG Count', neg_entry.count, neg_entry.uniq.count

    puts 'PARTIALLY MATCHED UPDATED ORDERS', updated_orders_with_matching_total
    puts 'Totals(sprint/bible)', updated_orders_total.to_f, bible_total.to_f

    puts 'COMPLETELY MATCHED UPDATED ORDERS', updated_orders_with_matching_total_with_tax, updated_orders_with_matching_total_with_tax.count
    puts 'Totals(sprint/bible)', updated_orders_total_with_tax.to_f, bible_total_with_tax.to_f

    puts 'NOT UC ENTRIES', not_uc_list
    puts 'NOT UC Totals(sprint/bible)', not_uc_list_total.to_f, not_uc_bible_total.to_f

    puts 'Repeating Rows', repeating_rows, repeating_rows.count
  end

  def update_vat_entries
    service = Services::Shared::Spreadsheets::CsvImporter.new('vat_cst_services.csv', 'seed_files_3')
    has_vat = []
    repeating_rows = []
    repeating_matching_bible_rows = 0
    repeating_matching_rows_total = 0

    updated_orders_with_matching_total_with_tax = []
    updated_orders_total_with_tax = 0
    bible_total_with_tax = 0

    updated_orders_with_matching_total = []
    updated_orders_total = 0
    bible_total = 0

    i = 0
    j = 0
    iteration = 1

    temporary_skip_list = ['BM0P0P2 - 200227', 'BM1A4X2 - 2001311', 'BM1A7S9 - 100000536', 'BM0Y9N6 - 10041', 'BM1B2L9 - 10094', 'BM9A5W9 - 10140', 'BM9C7Y1 - 10016', 'BM9C7Y1 - 10017', 'BM9C7Y1 - 10018', 'BM9C7Y1 - 10019']

    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      product_sku = x.get_column('Bm #').to_s.upcase

      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        sales_order = SalesOrder.find_by_old_order_number(order_number)
      else
        sales_order = SalesOrder.find_by_order_number(order_number.to_i)
      end
      if sales_order.present?
        current_order_row = product_sku + ' - ' + sales_order.order_number.to_s
        next if temporary_skip_list.include?(current_order_row) || x.get_column('Tax Rate').include?('#N/A')

        puts "ITERATION", iteration
        iteration = iteration + 1

        # CST/VAT
        if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST'))

          bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
          bible_order_tax_total = x.get_column('Tax Amount').to_f
          bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

          # AE
          next if bible_order_row_total.negative?
          # && bible_order_row_total_with_tax.negative?

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            quote_row = order_row.sales_quote_row
            tax_rate_percentage = x.get_column('Tax Rate').split('%')[0]
            tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first
            # _or_create

            quote_row.quantity = x.get_column('Order Qty').to_f if quote_row.quantity == x.get_column('Order Qty').to_f
            quote_row.unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.converted_unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.margin_percentage = x.get_column('Margin (In %)').split('%')[0]
            quote_row.tax_rate = tax_rate || nil
            quote_row.legacy_applicable_tax_percentage = tax_rate_percentage.to_d || nil
            quote_row.tax_type = x.get_column('Tax Type').to_s
            quote_row.inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)
            quote_row.created_at = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d') # check
            quote_row.save(validate: false)
            puts '****************************** QUOTE ROW SAVED ****************************************'
            quote_row.sales_quote.save(validate: false)
            puts '****************************** QUOTE SAVED ****************************************'

            order_row.quantity = x.get_column('Order Qty').to_f
            sales_order.mis_date = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            order_row.created_at = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d') # check
            order_row.save(validate: false)
            puts '****************************** ORDER ROW SAVED ****************************************'
            sales_order.save(validate: false)
            puts '****************************** ORDER SAVED ****************************************'

            row_total = order_row.total_selling_price.to_f.round(2)
            row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)
            # binding.pry
            if (row_total == bible_order_row_total) && (row_total_with_tax == bible_order_row_total_with_tax)
              if updated_orders_with_matching_total_with_tax.include?(x.get_column('Bm #') + '-' + x.get_column('So #'))
                repeating_rows.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
                repeating_matching_rows_total = repeating_matching_rows_total + row_total_with_tax
                repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
              else
                i = i + 1
                puts 'Matched order count', i
                updated_orders_with_matching_total_with_tax.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
                updated_orders_total_with_tax = updated_orders_total_with_tax + row_total_with_tax
                bible_total_with_tax = bible_total_with_tax + bible_order_row_total_with_tax
              end
            end

            if !((row_total == bible_order_row_total) && (row_total_with_tax == bible_order_row_total_with_tax))
              j = j + 1
              puts 'Mismatched order count', j
              updated_orders_with_matching_total.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
              updated_orders_total = updated_orders_total + row_total_with_tax
              bible_total = bible_total + bible_order_row_total_with_tax
            end
          end
        end
      end
    end
    puts 'HAS VAT', has_vat

    puts 'PARTIALLY MATCHED UPDATED ORDERS', updated_orders_with_matching_total
    puts 'Totals(sprint/bible)', updated_orders_total.to_f, bible_total.to_f

    puts 'COMPLETELY MATCHED UPDATED ORDERS', updated_orders_with_matching_total_with_tax, updated_orders_with_matching_total_with_tax.count
    puts 'Totals(sprint/bible)', updated_orders_total_with_tax.to_f, bible_total_with_tax.to_f

    puts 'Repeating Rows', repeating_rows, repeating_rows.count
  end

  def companies_export
    column_headers = ['Company Name', 'Company Alias', 'industry', 'state_name', 'company_contact', 'email', 'pan', 'company_type', 'Addresses count', 'Contacts count', 'Inquiries count']
    model = Company
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.includes({addresses: :state}, :company_contacts, :industry, :account).all.order(name: :asc).each do |record|
        company_name = record.name
        company_alias = record.account.name
        industry = (record.industry.name if record.industry.present?)
        state_name = (record.default_billing_address.present? ? record.default_billing_address.try(:state).try(:name) : record.addresses.first.try(:state).try(:name))
        company_contact = (record.default_company_contact.contact.full_name if record.default_company_contact.present?)
        email = record.email
        pan = record.pan
        company_type = record.company_type
        addresses_count = record.addresses.size
        contacts_count = record.contacts.size
        inquiries_count = record.inquiries.size
        writer << [company_name, company_alias, industry, state_name, company_contact, email, pan, company_type, addresses_count, contacts_count, inquiries_count]
      end
    end

    fetch_csv('companies_export.csv', csv_data)
  end

  def create_bible_orders
    # test_file
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    service.loop(nil) do |x|
      bible_total_with_tax = x.get_column('Total Selling Price').to_f + x.get_column('Tax Amount').to_f

      if bible_total_with_tax.negative?
        bible_order = BibleSalesOrder.where(inquiry_number: x.get_column('Inquiry Number').to_i,
                                            order_number: x.get_column('So #'),
                                            client_order_date: x.get_column('Client Order Date'),
                                            is_adjustment_entry: true).first_or_create! do |bible_order|
          bible_order.inside_sales_owner = x.get_column('Inside Sales Name')
          bible_order.company_name = x.get_column('Magento Company Name')
          bible_order.account_name = x.get_column('Company Alias')
          bible_order.currency = x.get_column('Price Currency')
          bible_order.document_rate = x.get_column('Document Rate')
          bible_order.metadata = []
        end
      else
        bible_order = BibleSalesOrder.where(inquiry_number: x.get_column('Inquiry Number').to_i,
                                            order_number: x.get_column('So #'),
                                            client_order_date: x.get_column('Client Order Date')).first_or_create! do |bible_order|
          bible_order.inside_sales_owner = x.get_column('Inside Sales Name')
          bible_order.company_name = x.get_column('Magento Company Name')
          bible_order.account_name = x.get_column('Company Alias')
          bible_order.mis_date = x.get_column('Order Date')
          bible_order.currency = x.get_column('Price Currency')
          bible_order.document_rate = x.get_column('Document Rate')
          bible_order.metadata = []
          bible_order.is_adjustment_entry = false
        end
      end

      if bible_order.present?
        skus_in_order = bible_order.metadata.map {|h| h['sku']}
        puts 'SKU STATUS', skus_in_order.include?(x.get_column('Bm #'))

        order_metadata = bible_order.metadata
        sku_data = {
            'sku': x.get_column('Bm #'),
            'description': x.get_column('Description'),
            'quantity': x.get_column('Order Qty'),
            'freight_tax_type': x.get_column('Freight	Tax Type'),
            'total_landed_cost': x.get_column('Total Landed Cost(Total buying price)').to_f,
            'unit_cost_price': x.get_column('unit cost price').to_f,
            'margin_amount': x.get_column('Margin').to_f,
            'margin_percentage': x.get_column('Margin (In %)'),
            'total_selling_price': x.get_column('Total Selling Price').to_f,
            'tax_rate': x.get_column('Tax Rate'),
            'tax_amount': x.get_column('Tax Amount').to_f,
            'unit_selling_price': x.get_column('Unit selling Price').to_f,
            'order_date': x.get_column('Order Date')
        }
        order_metadata.push(sku_data)
        bible_order.assign_attributes(metadata: order_metadata)
        bible_order.save
      end
    end

    bible_order_total = 0
    bible_order_tax = 0
    bible_order_total_with_tax = 0

    # BibleSalesOrder.all.each do |bible_order|
    #   bible_order.metadata.each do |line_item|
    #     bible_order_total = bible_order_total + line_item['total_selling_price']
    #     bible_order_tax = bible_order_tax + line_item['tax_amount']
    #     bible_order_total_with_tax = bible_order_total_with_tax + bible_order_total + bible_order_tax
    #     bible_order.update_attributes(order_total: bible_order_total, order_tax: bible_order_tax, order_total_with_tax: bible_order_total_with_tax)
    #   end
    # end
    puts 'BibleSO', BibleSalesOrder.count
  end

  def check_bible_total
    bible_order_total = 0
    BibleSalesOrder.all.each do |bible_order|
      bible_order.metadata.each do |line_item|
        bible_order_total = bible_order_total + line_item['total_selling_price']
      end
    end
    puts 'BIBLE ORDER TOTAL', bible_order_total
  end

  def flex_dump
    column_headers = ['Order Date', 'Order ID', 'PO Number', 'Part Number', 'Account Gp', 'Line Item Quantity', 'Line Item Net Total', 'Order Status', 'Account User Email', 'Shipping Address', 'Currency', 'Product Category', 'Part number Description']
    model = SalesOrder
    fc = []
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.joins(:company).where(companies: {id: 1847}).order(name: :asc).each do |order|
        if order.inquiry_currency.currency.id == 2 && order.calculated_total < 75000
          order.rows.each do |record|
            sales_order = record.sales_order
            order_date = sales_order.inquiry.customer_order_date.strftime('%F')
            order_id = sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.online_order_number : ''
            customer_po_number = sales_order.inquiry.customer_po_number
            part_number = record.product.sku
            account = sales_order.inquiry.company.name

            line_item_quantity = record.quantity
            line_item_net_total = record.total_selling_price.to_s
            sap_status = sales_order.remote_status
            user_email = sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.contact.email : 'sivakumar.ramu@flex.com'
            shipping_address = sales_order.inquiry.shipping_address
            currency = sales_order.inquiry.inquiry_currency.currency.name
            category = record.product.category.name
            part_number_description = record.product.name

            writer << [order_date, order_id, customer_po_number, part_number, account, line_item_quantity, line_item_net_total, sap_status, user_email, shipping_address, currency, category, part_number_description]
          end
        elsif order.inquiry_currency.currency.id != 2
          fc.push(order.order_number)
        end
      end
      puts 'FC', fc
    end

    fetch_csv('flex_export.csv', csv_data)
  end

  def invoices_export
    column_headers = [
        'Inquiry Number',
        'Invoice Number',
        'Invoice Date',
        'Invoice MIS Date',
        'Order Number',
        'Billing Address',
        'Shipping Address',
        # 'Order Date',
        'Customer Name',
        # 'Invoice Net Amount',
        # 'Freight / Packing',
        # 'Total Net Amount Including Freight',
        # 'Invoice Tax Amount',
        # 'Invoice Gross Amount',
        # 'Branch (Bill From)',
        'Invoice Status'
    ]

    model = SalesInvoice
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.where.not(sales_order_id: nil).where.not(metadata: nil).order(mis_date: :asc).find_each(batch_size: 2000) do |sales_invoice|
        sales_order = sales_invoice.sales_order
        inquiry = sales_invoice.inquiry

        inquiry_number = inquiry.inquiry_number.to_s
        invoice_number = sales_invoice.invoice_number
        invoice_date = sales_invoice.created_at.to_date.to_s
        invoice_mis_date = sales_invoice.mis_date.present? ? sales_invoice.mis_date.to_date.to_s : ''
        order_number = sales_order.order_number.to_s
        billing_address = inquiry.billing_address.to_s
        shipping_address = inquiry.shipping_address.to_s
        # order_date = sales_invoice.sales_order.created_at.to_date.to_s
        customer_name = inquiry.company.name.to_s
        # invoice_net_amount = (('%.2f' % (sales_order.calculated_total_cost.to_f - sales_invoice.metadata['shipping_amount'].to_f)) || '%.2f' % sales_order.calculated_total_cost_without_freight)
        # freight_and_packaging = (sales_invoice.metadata['shipping_amount'] || '%.2f' % sales_order.calculated_freight_cost_total)
        # total_with_freight = ('%.2f' % sales_invoice.metadata['subtotal'] if sales_invoice.metadata['subtotal'])
        # tax_amount = ('%.2f' % sales_invoice.metadata['tax_amount'] if sales_invoice.metadata['tax_amount'])
        # gross_amount = ('%.2f' % sales_invoice.metadata['grand_total'] if sales_invoice.metadata['grand_total'])
        # bill_from_branch = (inquiry.bill_from.address.state.name if inquiry.bill_from.present?)
        invoice_status = sales_order.remote_status

        # invoice_net_amount, freight_and_packaging, total_with_freight, tax_amount, gross_amount,order_date, bill_from_branch,
        writer << [inquiry_number, invoice_number, invoice_date, invoice_mis_date, order_number, billing_address, shipping_address, customer_name, invoice_status]
      end
    end

    fetch_csv('invoices_export.csv', csv_data)
  end
end


# order_row.unit_selling_price = x.get_column('Unit selling Price').to_f
# order_row.converted_unit_selling_price = x.get_column('Unit selling Price').to_f
# order_row.margin_percentage = (x.get_column('Margin (In %)').to_f / 100)
# order_row.tax_rate = tax_rate || nil
# order_row.legacy_applicable_tax_percentage = tax_rate || nil


# supplier = Company.acts_as_supplier.find_by_name(x.get_column('supplier')) || Company.acts_as_supplier.find_by_name('Local')
#         inquiry_product_supplier = InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
#         inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('unit cost price').to_f)
# row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize

#         row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
#         row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
#         row.save!
#

# order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first


#
# *************************************** outdated ************************************************
# mismatching_non_kit_non_ae_orders = ['201996', '202007', '202038', '202090', '2000015', '2000016', '2000041', '2000110', '2000144', '2000152', '2000170', '2000180', '2000228', '2000238', '2000262', '2000271', '2000272', '2000277', '2000279', '2000280', '2000299', '2000300', '2000318', '2000322', '2000327', '2000347', '2000355', '2000359', '2000360', '2000361', '2000362', '2000363', '2000364', '2000410', '2000411', '2000414', '2000426', '2000428', '2000431', '2000441', '2000451', '2000454', '2000455', '2000462', '2000466', '2000467', '2000468', '2000469', '2000470', '2000471', '2000480', '2000481', '2000482', '2000489', '2000490', '2000493', '2000495', '2000497', '2000510', '2000520', '2000521', '2000522', '2000524', '2000526', '2000527', '2000528', '2000530', '2000532', '2000533', '2000534', '2000536', '2000540', '2000543', '2000584', '2000585', '2000587', '2000588', '2000589', '2000597', '2000599', '2000604', '2000611', '2000614', '2000615', '2000616', '2000623', '2000624', '2000625', '2000629', '2000633', '2000634', '2000640', '2000644', '2000653', '2000654', '2000664', '2000665', '2000666', '2000667', '2000668', '2000671', '2000672', '2000673', '2000674', '2000676', '2000677', '2000679', '2000682', '2000683', '2000684', '2000685', '2000690', '2000696', '2000698', '2000700', '2000701', '2000702', '2000706', '2000719', '2000725', '2000749', '2000779', '2000823', '2000840', '2000942', '2001077', '2001133', '2001189', '2001250', '2001266', '2001279', '2001292', '2001307', '2001311', '2001319', '2001336', '2001345', '2001354', '2001363', '2001373', '2001661', '2001676', '2001677', '2001696', '2001707', '2001776', '2001777', '2001795', '2001798', '2001817', '2001818', '2001853', '2001865', '2001868', '2001873', '2001884', '2001892', '2001940', '2001978', '2002000', '2002012', '2002019', '2002044', '2002062', '2002077', '2002087', '2002107', '2002139', '2002158', '2002200', '2002203', '2002215', '2002230', '2002257', '2002270', '2002271', '2002272', '2002276', '2002435', '2002459', '2002531', '2002571', '2002572', '2002586', '2002599', '2002609', '2002663', '2002686', '2002689', '2002812', '2002944', '2002965', '2003055', '2003058', '2003066', '2003083', '2003085', '2003105', '2003120', '2003271', '2003287', '2003308', '2003411', '2003535', '2003550', '2003552', '2003564', '2003641', '10200023', '10200024', '10200074', '10200085', '10200086', '10200101', '10200106', '10200146', '10200175', '10200177', '10200203', '10200204', '10200205', '10200206', '10200216', '10200233', '10200237', '10210027', '10210031', '10210032', '10210033', '10210049', '10210062', '10210074', '10210084', '10210125', '10210128', '10210139', '10210145', '10210150', '10210151', '10210161', '10210163', '10210198', '10210199', '10210214', '10210216', '10210226', '10210245', '10210251', '10210294', '10210294', '10210295', '10210296', '10210301', '10210301', '10210314', '10210316', '10210316', '10210335', '10210348', '10210350', '10210353', '10210365', '10210389', '10210391', '10210399', '10210403', '10210406', '10210425', '10210454', '10210460', '10210461', '10210462', '10210462', '10210469', '10210471', '10210485', '10210486', '10210491', '10210494', '10210528', '10210532', '10210537', '10210544', '10210559', '10210560', '10210564', '10210566', '10210575', '10210580', '10210583', '10210586', '10210603', '10210604', '10210605', '10210606', '10210607', '10210608', '10210609', '10210611', '10210614', '10210615', '10210617', '10210630', '10210645', '10210662', '10210670', '10210671', '10210672', '10210673', '10210681', '10210690', '10210694', '10210696', '10210698', '10210707', '10210709', '10210716', '10210726', '10210736', '10210761', '10210765', '10210766', '10210771', '10210789', '10210792', '10210794', '10210796', '10210799', '10210803', '10210810', '10210811', '10210826', '10210831', '10210846', '10210856', '10210857', '10210875', '10210891', '10210896', '10210897', '10210903', '10210904', '10210911', '10210915', '10210915', '10210919', '10210921', '10210935', '10210958', '10210962', '10210970', '10210971', '10210975', '10210979', '10210980', '10210981', '10210987', '10210992', '10210993', '10210998', '10211002', '10211012', '10211013', '10211019', '10211021', '10211023', '10211024', '10211043', '10211046', '10211048', '10211049', '10211050', '10211074', '10211103', '10211107', '10211111', '10211118', '10211131', '10211132', '10211133', '10211179', '10211189', '10211235', '10211258', '10211295', '10211456', '10211560', '10211737', '10212228', '10300005', '10300006', '10300015', '10300022', '10300024', '10300026', '10300029', '10300030', '10300031', '10300034', '10300036', '10300037', '10300048', '10300052', '10300053', '10300054', '10300059', '10300065', '10300067', '10300068', '10300071', '10300076', '10400009', '10610009', '10610010', '10610037', '10610047', '10610052', '10610066', '10610082', '10610090', '10610094', '10610103', '10610107', '10610111', '10610118', '10610136', '10610143', '10610147', '10610147', '10610150', '10610187', '10610195', '10610198', '10610202', '10610207', '10610212', '10610218', '10610239', '10610241', '10610254', '10610255', '10610278', '10610287', '10610306', '10610318', '10610342', '10610345', '10610348', '10610363', '10610370', '10610383', '10610383', '10610389', '10610410', '10610423', '10610427', '10610428', '10610432', '10610433', '10610435', '10610465', '10610472', '10610498', '10610509', '10610874', '10710005', '10910022', '10910022', '10910035', '10910039', '10910044', '10910067', '10910069', '10910070', '10910071', '10910074', '10910087', '10910088', '10910096', '10910109', '10910110', '10910115', '10910123', '10910128', '10910129', '10910145', '10910152', '11210010', '11210027', '11210030', '11210033', '11210038', '11210039', '11210041', '11210045', '11210046', '11210060', '11210062', '11210065', '11210066', '11210075', '11210079', '11210081', '11410013', '11410018', '11410026', '99999001', '99999003', '99999004', '99999007', '99999012', '99999013', '99999036', '99999038', '99999039', '99999053', '99999055', '99999063', '99999088', '99999089', '2000134-1', '2000179-1', '2000315-1', '2000380-2', '2000387-1', 'Order1', 'Order2', '10210957', '10210957', '10210957']
#
# mismatch_after_first_correction = ['201996', '202007', '202090', '2000485', '2001311', '2001363', '2001775', '2002230', '2002663', '10210580', '10210780', '10210975', '10211002', '10211013', '10211030', '10211112', '10211179', '10300052', '10610009', '10610052', '10610230', '10610422', '10910112', '99999008', '99999014', '99999045', '210200096']
#
# negative_entries = ['10210151', '10210294', '10210301', '10210316', '10210606', '10210766', '10210915', '10610147', '10610383', '10910022', '11410018']