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
    column_headers = ['Inside Sales Name', 'Client Order Date', 'Price Currency', 'Document Rate', 'Magento Company Name', 'Company Alias', 'Inquiry Number', 'So #', 'Order Date', 'Bm #', 'Description', 'Order Qty', 'Unit Selling Price', 'Freight', 'Tax Type', 'Tax Rate', 'Tax Amount', 'Total Selling Price', 'Total Landed Cost', 'Unit cost price', 'Margin', 'Margin (In %)', 'Kit', 'AE', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']
    matching_orders = []
    repeating_skus = []
    missing_skus = []
    missing_orders = []
    iteration = 1
    multiple_not_booked_orders = []
    matching_rows_total = 0
    matching_bible_rows = 0

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        puts "********************************* ITERATION ************************************", iteration
        iteration = iteration + 1
        is_adjustment_entry = 'No'
        order_number = x.get_column('So #')
        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        next if bible_order_row_total.to_f.zero?

        if bible_order_row_total.negative?
          sales_order = SalesOrder.where(parent_id: order_number, is_credit_note_entry: true).first
        elsif order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          if order_number == 'Not Booked'
            inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders

            if inquiry_orders.count > 1
              multiple_not_booked_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
              sales_order = inquiry_orders.where(old_order_number: 'Not Booked').first
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

            # adjustment entries
            if (row_total == -(bible_order_row_total)) || (row_total_with_tax == -(bible_order_row_total_with_tax)) || bible_order_row_total_with_tax.negative? || bible_order_row_total.negative?
              is_adjustment_entry = 'Yes'
            end

            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)

              # KIT check
              if sales_order.calculated_total.to_f.round(2) == bible_order_row_total &&
                  sales_order.calculated_total_with_tax.to_f.round(2) == bible_order_row_total_with_tax
                writer << [x.get_column('Inside Sales Name'),
                           x.get_column('Client Order Date'),
                           x.get_column('Price Currency'),
                           x.get_column('Document Rate'),
                           x.get_column('Magento Company Name').gsub(';', ' '),
                           x.get_column('Company Alias').gsub(';', ' '),
                           x.get_column('Inquiry Number'),
                           x.get_column('So #'),
                           x.get_column('Order Date'),
                           x.get_column('Bm #'),
                           x.get_column('Description').gsub(';', ' '),
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
                           x.get_column('Magento Company Name').gsub(';', ' '),
                           x.get_column('Company Alias').gsub(';', ' '),
                           x.get_column('Inquiry Number'),
                           x.get_column('So #'),
                           x.get_column('Order Date'),
                           x.get_column('Bm #'),
                           x.get_column('Description').gsub(';', ' '),
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

    fetch_csv('Bible_mismatch_initial_run.csv', csv_data)
  end

  def update_non_kit_non_ae_except_zero_tsp
    service = Services::Shared::Spreadsheets::CsvImporter.new('initial_mismatch.csv', 'seed_files_3')
    neg_entry = []
    repeating_rows = []
    quantity_mismatch = []
    multiple_not_booked_orders = []
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

    duplicate_skus = ['BM0P0P2 - 200227', 'BM1A4X2 - 2001311', 'BM1A7S9 - 100000536', 'BM0Y9N6 - 10041', 'BM1B2L9 - 10094', 'BM9A5W9 - 10140', 'BM9C7Y1 - 10016', 'BM9C7Y1 - 10017', 'BM9C7Y1 - 10018', 'BM9C7Y1 - 10019']

    service.loop(nil) do |x|
      next if x.get_column('Kit') == 'Yes'
      order_number = x.get_column('So #')
      product_sku = x.get_column('Bm #').to_s.upcase

      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        if order_number == 'Not Booked'
          inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders

          if inquiry_orders.count > 1
            multiple_not_booked_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
            sales_order = inquiry_orders.where(old_order_number: 'Not Booked').first
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
        puts "******************************** ITERATION *******************************", iteration
        iteration = iteration + 1

        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        # AE
        if bible_order_row_total.negative? && bible_order_row_total_with_tax.negative?
          neg_entry.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
        end

        if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
          order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
          quote_row = order_row.sales_quote_row

          # .scan(/^\d*(?:\.\d+)?/)[0]
          if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))
            tax_rate_percentage = x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_d
            tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first_or_create!
          else
            tax_rate_percentage = x.get_column('Tax Rate').split('%')[0]
            tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first
          end

          if quote_row.quantity != x.get_column('Order Qty').to_f
            quantity_mismatch.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
          end
          quote_row.quantity = x.get_column('Order Qty').to_f
          quote_row.unit_selling_price = x.get_column('Unit Selling Price').to_f
          quote_row.converted_unit_selling_price = x.get_column('Unit Selling Price').to_f
          quote_row.margin_percentage = x.get_column('Margin (In %)').split('%')[0].to_d
          quote_row.tax_rate = tax_rate || nil
          quote_row.tax_type = x.get_column('Tax Type') if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))
          quote_row.legacy_applicable_tax_percentage = tax_rate_percentage.to_d || nil
          quote_row.inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)

          quote_row.created_at = x.get_column('Order Date') == '#N/A' ? sales_order.created_at : Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
          quote_row.save(validate: false)
          puts '****************************** QUOTE ROW SAVED ****************************************'
          quote_row.sales_quote.save(validate: false)
          puts '****************************** QUOTE SAVED ****************************************'

          order_row.quantity = x.get_column('Order Qty').to_f
          # cross-check
          sales_order.mis_date = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d') if x.get_column('Order Date') != '#N/A'
          order_row.created_at = x.get_column('Order Date') == '#N/A' ? sales_order.created_at : Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
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
          end
        else
          # add missing skus in sprint
        end
      else
        # add missing orders in sprint
      end
    end
    puts 'PARTIALLY MATCHED UPDATED ORDERS', updated_orders_with_matching_total
    puts 'Totals(sprint/bible)', updated_orders_total.to_f, bible_total.to_f

    puts 'COMPLETELY MATCHED UPDATED ORDERS', updated_orders_with_matching_total_with_tax, updated_orders_with_matching_total_with_tax.count
    puts 'Totals(sprint/bible)', updated_orders_total_with_tax.to_f, bible_total_with_tax.to_f
    puts "QMismatch", quantity_mismatch
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

  def flex_sku_wise_order_export
    column_headers = ['Inquiry', 'Customer PO Number', 'Sales Order', 'Order Status', 'Order Date', 'Billing Contact', 'Shipping Contact', 'SKU', 'SKU NAME', 'SKU Quantity', 'SKU Total', 'SKU Total with tax']
    model = SalesOrder
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.remote_approved.joins(:company).where(companies: {id: 1847}).order(name: :asc).each do |order|
        order.rows.each do |record|
          sales_order = record.sales_order
          inquiry = sales_order.inquiry.inquiry_number
          customer_po_number = sales_order.inquiry.customer_po_number
          order_number = sales_order.order_number.to_s
          order_status = sales_order.remote_status
          order_date = sales_order.inquiry.customer_order_date.strftime('%F')
          billing_contact = sales_order.inquiry.billing_contact.name.to_s + '-' + (sales_order.inquiry.billing_contact.mobile || sales_order.inquiry.billing_contact.telephone).to_s
          shipping_contact = sales_order.inquiry.shipping_contact.name.to_s + '-' + (sales_order.inquiry.shipping_contact.mobile || sales_order.inquiry.shipping_contact.telephone).to_s
          sku = record.product.sku
          sku_name = record.product.name
          sku_quantity = record.quantity
          sku_total = record.total_selling_price.to_s
          sku_total_with_tax = record.total_selling_price_with_tax.to_s

          writer << [inquiry, customer_po_number, order_number, order_status, order_date, billing_contact, shipping_contact, sku, sku_name, sku_quantity, sku_total, sku_total_with_tax]
        end
      end
    end

    fetch_csv('flex_sku_wise_order_export12.csv', csv_data)
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
