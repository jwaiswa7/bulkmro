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
    ae_entries = []
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
          if !bible_order_row_total.negative?
            missing_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
          else
            ae_entries.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
          end
        end
      end
      puts 'Matching orders uniq', matching_orders.uniq.count
      puts 'Matching orders', matching_orders.count
      puts 'Totals(Bible, sprint)', matching_bible_rows.to_f, matching_rows_total.to_f
      puts 'REPEATING SKUS', repeating_skus
      puts 'MISSING SKUs', missing_skus, missing_skus.count
      puts 'MISSING ORDERS', missing_orders, missing_orders.count
      puts 'MULTIPLE NOT BOOKED ORDERS', multiple_not_booked_orders, multiple_not_booked_orders.count
      puts "AE ENTRIES", ae_entries, ae_entries.count
    end

    fetch_csv('new_initial_mismatch.csv', csv_data)
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

    batch1 = ['BM9B3J9-200092', 'BM0C7P6-200187', 'BM0C7Q5-200188', 'BM1A6Q6-200202', 'BM1A6Q7-200202', 'BM1A6Q8-200202', 'BM1A6Q9-200202', 'BM1A6R0-200202', 'BM1A6R1-200202', 'BM1A6R2-200202', 'BM1A6R3-200202', 'BM1A6R4-200202', 'BM1A6R5-200202', 'BM1A6R6-200202', 'BM1A6R7-200202', 'BM1A6R9-200202', 'BM1A6S0-200202', 'BM1A6S1-200202', 'BM1A6S2-200202', 'BM1A6S4-200202', 'BM1A6S6-200202', 'BM1A6S7-200202', 'BM1A6S8-200202', 'BM1A6S9-200202', 'BM1A6T0-200202', 'BM1A6T3-200202', 'BM1A6T4-200202', 'BM1A6T5-200202', 'BM1A6T6-200202', 'BM1A6T7-200202', 'BM1A6T8-200202', 'BM1A6T9-200202', 'BM1A6U0-200202', 'BM1A6U1-200202', 'BM1A6U2-200202', 'BM1A6U3-200202', 'BM1A6U4-200202', 'BM1A6U7-200202', 'BM1A6U8-200202', 'BM1A6U9-200202', 'BM1A6V0-200202', 'BM1A6V1-200202', 'BM1A6V2-200202', 'BM1A6V3-200202', 'BM1A6V5-200202', 'BM1A6V7-200202', 'BM1A6V8-200202', 'BM1A6V9-200202', 'BM1A6W0-200202', 'BM1A6W7-200202', 'BM1A6W8-200202', 'BM1A6X2-200202', 'BM1A6X3-200202', 'BM1A6X4-200202', 'BM1A6X5-200202', 'BM1A6X6-200202', 'BM1A6Y1-200202', 'BM1A6Y2-200202', 'BM1A6Y3-200202', 'BM1A6Y4-200202', 'BM1A6Z5-200202', 'BM1A7A1-200202', 'BM0C7A6-200208', 'BM0C7C1-200208', 'BM0C7F4-200208', 'BM0C7G2-200208', 'BM0C7G4-200208', 'BM0C7I4-200208', 'BM0C7J0-200208', 'BM0C7J1-200208', 'BM0C7O7-200208', 'BM0C7P6-200208', 'BM0C7Q8-200208', 'BM0C7R1-200208', 'BM0C7R2-200208', 'BM0C7R3-200208', 'BM0C7R4-200208', 'BM0C7R6-200208', 'BM0C7R7-200208', 'BM0C7R8-200208', 'BM0C7R9-200208', 'BM0C7S0-200208', 'BM0C7S2-200208', 'BM0C7T6-200208', 'BM0C7V0-200208', 'BM0C8E9-200208', 'BM0C8F1-200208', 'BM0C8G8-200208', 'BM0C8H2-200208', 'BM0C8T9-200208', 'BM0C8W6-200208', 'BM0C9A8-200208', 'BM0C9A9-200208', 'BM0C9B4-200208', 'BM0C9B8-200208', 'BM0C9B9-200208', 'BM0C9C1-200208', 'BM0C9D0-200208', 'BM0C9E2-200208', 'BM0C9E5-200208', 'BM0C9E6-200208', 'BM0C9E7-200208', 'BM0C9F9-200208', 'BM0C9I8-200208', 'BM0C9M8-200208', 'BM1A7Z0-200208', 'BM1A8E3-200208', 'BM0C7G2-200210', 'BM0C7N8-200210', 'BM0C7T2-200210', 'BM0C8L7-200210', 'BM0C8L8-200210', 'BM0C8U4-200210', 'BM0C8U7-200210', 'BM0C8U8-200210', 'BM0C8U9-200210', 'BM0C8V0-200210', 'BM0C8V1-200210', 'BM0C8X3-200210', 'BM0C8X4-200210', 'BM0C8X5-200210', 'BM0C8X8-200210', 'BM0C9G5-200210', 'BM1A8V8-200212', 'BM1A8V9-200212', 'BM1A8W0-200212', 'BM1A8W1-200212', 'BM1A8W2-200212', 'BM1A8W3-200212', 'BM1A8W4-200212', 'BM1A8W5-200212', 'BM1A8W6-200212', 'BM1A8W7-200212', 'BM1A8W8-200212', 'BM1A8W9-200212', 'BM1A4U6-200237', 'BM0C8U4-200256', 'BM1A3O0-200256', 'BM1A3O1-200256', 'BM1A3O3-200256', 'BM1A3O7-200256', 'BM1A3O8-200256', 'BM1A3O9-200256', 'BM1A3P0-200256', 'BM1A3P1-200256', 'BM1A3P2-200256', 'BM1A3P4-200256', 'BM1A3P5-200256', 'BM1A3P6-200256', 'BM1A3P7-200256', 'BM1A3Q2-200256', 'BM1A3Q3-200256', 'BM1A8I0-200260', 'BM9A2Y4-200318', 'BM0Z0M7-200582', 'BM9B6X2-200599', 'BM1G0Q7-200639', 'BM1G0Q8-200639', 'BM9C7W1-200852', 'BM1G0Q7-200973', 'BM1G0Q7-200974', 'BM9C8Y1-200982', 'BM1G0Q6-200991', 'BM9A7P6-201050', 'BM9A7P7-201050', 'BM9A7P8-201050', 'BM9E2S4-201484', 'BM9E1L9-201494', 'BM9C3W3-201585', 'BM1B2L6-201751', 'BM9E9C8-201806', 'BM9E9C9-201806', 'BM9E3G4-201807', 'BM9E8T5-201828', 'BM9E8T6-201828', 'BM9E8T7-201828', 'BM9E8T8-201828', 'BM9E8T9-201828', 'BM9E8U1-201828', 'BM9E8U2-201828', 'BM9E8U3-201828', 'BM9E8U4-201828', 'BM9E8U5-201828', 'BM9E8U6-201828', 'BM9E8U7-201828', 'BM9E8U8-201828', 'BM9E8V1-201828', 'BM9E8V2-201828', 'BM9E8V4-201828', 'BM9E8V5-201828', 'BM9E8V6-201828', 'BM9E8V8-201828', 'BM9E8V9-201828', 'BM9E8W1-201828', 'BM9F6T4-201949', 'BM9F6T5-201949', 'BM9F6T6-201949', 'BM9F6T7-201949', 'BM9F6T8-201949', 'BM9F6T9-201949', 'BM9F6U1-201949', 'BM9F6U2-201949', 'BM9F6U3-201949', 'BM9F6U4-201949', 'BM9F6U5-201949', 'BM9F5E1-202007', 'BM9F5E3-202008', 'BM9F9U9-202010', 'BM9F6T3-202038', 'BM9G1U8-2000034', 'BM9F9C8-2000047', 'BM9E8C4-2000099', 'BM9E8C5-2000099', 'BM9E8C6-2000099', 'BM9G5B7-2000127', 'BM0C9A0-2000165', 'BM0K9O8-2000166', 'BM0C7B3-2000167', 'BM0C7F6-2000197', 'BM0C7F5-2000199', 'BM0C7F6-2000200', 'BM0C7F6-2000202', 'BM0K9O8-2000204', 'BM0C7F6-2000205', 'BM0C7F5-2000206', 'BM0C7F5-2000207', 'BM0C7F5-2000208', 'BM0C7I4-2000209', 'BM0C7F5-2000210', 'BM0C7F5-2000211', 'BM0C7B3-2000213', 'BM0C7A1-2000214', 'BM0C7I4-2000216', 'BM0C7F8-2000217', 'BM0C7B3-2000218', 'BM1G0M3-2000219', 'BM1G0M3-2000220', 'BM0C7B3-2000221', 'BM0K9O8-2000222', 'BM0C7C7-2000223', 'BM0C7F6-2000224', 'BM1G0M3-2000226', 'BM0C7F6-2000227', 'BM0C7B3-2000228', 'BM0C7B3-2000233', 'BM0Q8Y4-2000234', 'BM0C8I0-2000235', 'BM0C9A0-2000237', 'BM1G0F0-2000238', 'BM0C7U2-2000239', 'BM0C7B3-2000240', 'BM0C7B3-2000242', 'BM0C7U2-2000243', 'BM0C7B3-2000244', 'BM0C7A0-2000247', 'BM9F5H1-2000255', 'BM0C7F8-2000256', 'BM0C7V0-2000258', 'BM9F5H1-2000259', 'BM0O6H8-2000260', 'BM0C7Q0-2000263', 'BM0C7B3-2000264', 'BM0O6H8-2000265', 'BM0C7D3-2000266', 'BM1G0E9-2000267', 'BM9G8S6-2000272', 'BM9G5N4-2000300', 'BM9G5N5-2000300', 'BM9G5N6-2000300', 'BM9G5N7-2000300', 'BM9G5N8-2000300', 'BM1G0F0-2000322', 'BM0H8A4-2000328', 'BM0C7D5-2000348', 'BM0C7I3-2000348', 'BM9G3W2-2000355', 'BM9G3W3-2000355', 'BM9G3W4-2000355', 'BM9G3W5-2000355', 'BM0Q8Y4-2000359', 'BM0O6H8-2000360', 'BM0C9A0-2000361', 'BM0C7U5-2000362', 'BM1G0E9-2000364', 'BM0C9A0-2000371', 'BM0C8I0-2000372', 'BM0C7P6-2000374', 'BM0O6H8-2000376', 'BM0C7B3-2000377', 'BM0C7B3-2000378', 'BM0C7V1-2000382', 'BM0C7Q0-2000389', 'BM9E4Z6-2000422', 'BM9E4Z7-2000422', 'BM9E4Z8-2000422', 'BM9E4Z9-2000422', 'BM9E5A1-2000422', 'BM9E5A2-2000422', 'BM0K9O8-2000451', 'BM9A6Z6-2000454', 'BM0C7U5-2000455', 'BM0C7V1-2000466', 'BM0C7G2-2000467', 'BM0Q8Y4-2000468', 'BM0O6H8-2000469', 'BM9G8G5-2000470', 'BM0C7I3-2000471', 'BM0C7U8-2000480', 'BM0C7U9-2000481', 'BM0C7U5-2000482', 'BM9H3P1-2000489', 'BM9H3P2-2000489', 'BM9H3P3-2000489', 'BM9H3P4-2000489', 'BM9F3F3-2000493', 'BM0C7B3-2000495', 'BM0O6H8-2000497', 'BM0C7H1-2000520', 'BM0C7V1-2000521', 'BM0C7G1-2000522', 'BM0C7B3-2000524', 'BM0C7B3-2000527', 'BM0C7B3-2000528', 'BM0C7A1-2000530', 'BM4K3W1-2000532', 'BM4K3W1-2000533', 'BM4K3W1-2000534', 'BM9F5G2-2000540', 'BM0C7B3-2000584', 'BM0Q8Y4-2000585', 'BM0C7V1-2000587', 'BM0C7B3-2000588', 'BM0Q8Y4-2000589', 'BM0C7B3-2000597', 'BM4K3W1-2000599', 'BM0C7B3-2000604', 'BM9G9U7-2000611', 'BM9G9U8-2000611', 'BM0C7B3-2000614', 'BM0C7U9-2000616', 'BM0C7Q0-2000623', 'BM0Q8X8-2000624', 'BM4K3W1-2000625', 'BM0O6H8-2000654', 'BM0C7B3-2000664', 'BM0C7I3-2000665', 'BM0C7B3-2000666', 'BM3U7A3-2000667', 'BM0C7B3-2000668', 'BM4K3W1-2000671', 'BM0C7B3-2000673', 'BM0C7B3-2000674', 'BM0C6Z9-2000676', 'BM0C6Z9-2000677', 'BM0C7B3-2000679', 'BM0C7P6-2000682', 'BM0C7P6-2000683', 'BM0C7P6-2000684', 'BM0C7B3-2000685', 'BM0C7B3-2000696', 'BM0C7B3-2000698', 'BM0C7B3-2000701', 'BM9H9C3-2000702', 'BM9H9C4-2000702', 'BM9K1B2-2001676', 'BM9K1B4-2001676', 'BM9K6Q2-2001940', 'BM9G3J3-2002215', 'BM9G3J8-2002215', 'BM1G0F0-2002230', 'BM9J8H5-2002571', 'BM9K2R8-2002572', 'BM1B0F3-2002944', 'BM9G4S3-2002944', 'BM9A8D3-2003085', 'BM9K9E1-2003085', 'BM9M1X9-2003105', 'BM4H8M5-2003426', 'BM9D3R7-2003561', 'BM9G1U8-2003641', 'BM9G8E5-10200024', 'BM9N6G2-10200177', 'BM9N7J5-10200216', 'BM9J4Y5-10200237', 'BM1A8J3-10210027', 'BM9M8U6-10210027', 'BM9M8U7-10210027', 'BM9M8U9-10210027', 'BM9M8V1-10210027', 'BM9M8V2-10210027', 'BM9M8V3-10210027', 'BM9M8V4-10210027', 'BME3Y1M-10210027', 'BM9N1F9-10210033', 'BM00008-10210062', 'BM9L7Q9-10210074', 'BM9L7R3-10210074', 'BM9L7R9-10210074', 'BM9L7S1-10210074', 'BM9L7S2-10210074', 'BM9L7S3-10210074', 'BM9L7S4-10210074', 'BM9P2Y7-10210125', 'BM9K1C6-10210128', 'BM9K1C7-10210128', 'BM9L6D8-10210128', 'BM9L6D9-10210128', 'BM9P8H5-10210150', 'BM9Q2C6-10210150', 'BM9R2H4-10210150', 'BM9R4Y5-10210150', 'BM9R7E3-10210150', 'BM9R7U2-10210150', 'BM9U9B5-10210150', 'BM9W8U3-10210150', 'BM9Z6T2-10210150', 'BM9N9T3-10210161', 'BM9N9X2-10210161', 'BM9P2Y7-10210198', 'BM9X5Y5-10210216', 'BM9Z3S4-10210216', 'BM9P3Y4-10210294', 'BM9P3Y4-10210295', 'BM9P2Y7-10210296', 'BM9Q8W4-10210301', 'BM9P3K4-10210316', 'BM9S5Q9-10210399', 'BM9U7C3-10210399', 'BM9Q5T5-10210403', 'BM9P4U7-10210462', 'BM9P5T8-10210469', 'BM9P6M1-10210544', 'BM00008-10210559', 'BM9P8D8-10210559', 'BM9Y8U9-10210559', 'BM9E4Z8-10210566', 'BM9Q5P6-10210580', 'BM9S5M2-10210580', 'BM9T4N8-10210580', 'BM9V3M1-10210580', 'BM9X7E1-10210580', 'BM9P6K4-10210603', 'BM0K8J5-10210604', 'BM9Q4U1-10210605', 'BM9R6B6-10210605', 'BM9T3G3-10210605', 'BM9T3V6-10210605', 'BM9W4E7-10210605', 'BM9X2P9-10210605', 'BM9Y7C7-10210605', 'BM9Z1P8-10210605', 'BM9S1G7-10210608', 'BM00008-10210645', 'BM9P7N1-10210690', 'BM9Q5P6-10210696', 'BM9T4N8-10210696', 'BM9X7E1-10210696', 'BM9W3S5-10210707', 'BM00008-10210709', 'BM9P7B6-10210736', 'BM9V5V1-10210765', 'BM9Y1Q7-10210766', 'BM9P5T8-10210771', 'BM9Z6F3-10210799', 'BM9S4G5-10210803', 'BM00008-10210821', 'BM9S1G7-10210821', 'BM9P7M9-10210826', 'BM9M9Q3-10210831', 'BM9P4U7-10210846', 'BM9P9Y2-10210875', 'BM00008-10210891', 'BM9R1F9-10210891', 'BM9Z6F3-10210891', 'BM9W9B9-10210915', 'BM9Y5M1-10210915', 'BM00008-10210957', 'BM9W3S5-10210957', 'BM9R1F9-10210958', 'BM9S4G5-10210958', 'BM9Q1T8-10210975', 'BM9Q1Z7-10210979', 'BM9Q2B8-10210981', 'BM9Q7U5-10210992', 'BM9Q1T8-10211002', 'BM9Q1T8-10211012', 'BM9Q1T8-10211013', 'BM9Z6S4-10211021', 'BM9Z9T9-10211024', 'BM9S1T6-10211043', 'BM9X1S1-10211043', 'BM9Z6D6-10211043', 'BM9U6V6-10211118', 'BM9Q3J6-10211131', 'BM9R1P5-10211132', 'BM9P5R9-10211235', 'BM9E4Z0-10211295', 'BM9T5N6-10211295', 'BM9C6B7-10211737', 'BM9M9V9-10212228', 'BM9H9M5-10300005', 'BM9H9M6-10300005', 'BM9H9M7-10300005', 'BM9H5P9-10300006', 'BM9H5Q1-10300006', 'BMC7A4H-10300015', 'BM4H8M5-10300022', 'BM9G8F3-10300026', 'BM1A8F6-10300031', 'BM4H8N6-10300034', 'BMC4J0D-10300037', 'BM3X4Y9-10300048', 'BM1A8F6-10300052', 'BM9J1B9-10300065', 'BM1A8F3-10300067', 'BM1A8F5-10300067', 'BM1A8F6-10300067', 'BM00008-10300068', 'BM9H5P9-10300068', 'BM9N3T4-10300071', 'BM9N4A2-10300071', 'BM4H8P3-10300076', 'BM9N2M6-10400009', 'BM9E9F8-10610009', 'BM3B8G1-10610052', 'BM9N3P1-10610052', 'BM9W9D7-10610052', 'BM9Y2T3-10610052', 'BM9Z7B2-10610052', 'BM9N7Q4-10610118', 'BM9Z1X9-10610136', 'BM9E9F8-10610147', 'BM9P6J6-10610207', 'BM9P5W6-10610212', 'BM9P5W8-10610212', 'BM9P5W9-10610212', 'BM9P5X1-10610212', 'BM1A8F6-10610255', 'BM9P2X7-10610255', 'BM4H8P3-10610278', 'BM3B8G1-10610389', 'BM9P4N7-10610509', 'BM9P5M7-10910022', 'BM9Q8J8-10910022', 'BM9W6T1-10910022', 'BM0K8J5-10910074', 'BM0O7G3-10910110', 'BM9Y7A9-11210038', 'BM9M5D3-11410013', 'BM9T6Q9-11410018', 'BM9V3C6-11410018', 'BM9M5D3-11410026', 'BM9F4Z1-99999003', 'BM9G3P5-99999004', 'BM9F4X2-99999007', 'BM9G6L5-99999007', 'BM4H8M5-99999053', 'BM9G8N5-99999053', 'BM9F5U2-99999055', 'BM9B8R8-99999086', 'BM4H8O6-99999088', 'BM3X4Y9-99999089', 'BM0C7K0-100000165', 'BM0C7D8-100000171', 'BM1A6Q7-100000179', 'BM0C7Q5-100000193', 'BM0L8L7-100000196', 'BM0C7P6-100000197', 'BM0C9I8-100000206', 'BM0C7Q5-100000210', 'BM1A3Z4-100000218', 'BM0C9I8-100000223', 'BM0C7I4-100000224', 'BM0C7V0-100000228', 'BM0C7I4-100000231', 'BM0C7I4-100000237', 'BM0C7F8-100000247', 'BM1A8D2-100000353', 'BM1A7C3-100000398', 'BM1A7J0-100000405', 'BM1A7G8-100000422', 'BM1A6O7-100000432', 'BM1A6J2-100000498', 'BM1A6J3-100000498', 'BM1A7R3-100000599', 'BM1A8P1-100000612', 'BM1A8P2-100000612', 'BM1A8P3-100000612', 'BM1A8P4-100000612', 'BM1A8P5-100000612', 'BM1A6B1-100000630', 'BM1A8P2-100000630', 'BM1A8P3-100000630', 'BM1A6C9-100000661', 'BM1E1E7-100000674', 'BM0C8Z1-100000678', 'BM0C7T2-100000680', 'BM0C9M8-100000702', 'BM0C9M8-100000706', 'BM0C7T2-100000709', 'BM0C9M8-100000710', 'BM0C9M8-100000711', 'BM0C7D8-100000768', 'BM1A6N2-100000786', 'BM1A6N4-100000786', 'BM0C9M8-100000787', 'BM1A5O3-100000803', 'BM1A7C9-100000810', 'BM1A7D0-100000810', 'BM1A7D1-100000810', 'BM1A7D2-100000810', 'BM1A7D3-100000810', 'BM1A7D4-100000810', 'BM1A7D5-100000810', 'BM1A7D6-100000810', 'BM1A7D7-100000810', 'BM1A7D8-100000810', 'BM1A7E1-100000810', 'BM1A5E2-100000829', 'BM1A5E3-100000829', 'BM1A5E4-100000829', 'BM1A5E5-100000829', 'BM1A5E6-100000829', 'BM1A5E7-100000829', 'BM1A5E8-100000829', 'BM1A5E9-100000829', 'BM1A5F0-100000829', 'BM1A5F1-100000829', 'BM1A8H4-100000842', 'BM1A8H5-100000842', 'BM1A8H6-100000842', 'BM1A6V1-100000861', 'BM0C7O6-100000875', 'BM0C7G1-100000876', 'BM0C7R0-100000876', 'BM0C7O6-100000877', 'BM0Z0Z8-100000894', 'BM1A6G2-100000895', 'BM1A6G3-100000895', 'BM1A6G4-100000895', 'BM0C7G0-100000897', 'BM0C8E6-100000897', 'BM1A3T5-100000897', 'BM1A3Z3-100000897', 'BM1A8L4-100000897', 'BM1B2L6-100000911', 'BM0C7C9-100000914', 'BM0C7C9-100000915', 'BM0C8Z1-100000916', 'BM0C7C9-100000936', 'BM0C7C9-100000937', 'BM1A6J6-100000946', 'BM1A6J8-100000946', 'BM1A8J2-100000957', 'BM9A2Y4-100001134', 'BM0C7F6-100001147', 'BM9A2Y4-100000146-1', 'BM0C7B2-100000195-1', 'BM1A8C0-100000355-2', 'BM1A8C1-100000355-2', 'BM1A8C2-100000355-2', 'BM1A8C3-100000355-2', 'BM1A8C4-100000355-2', 'BM1A8C5-100000355-2', 'BM1A8C6-100000355-2', 'BM1A8C7-100000355-2', 'BM1A8C8-100000355-2', 'BM1A8C9-100000355-2', 'BM1A8D0-100000355-2', 'BM1A8J2-100000357-1', 'BM1A8J3-100000357-1', 'BM1A7U6-100000360-2', 'BM1A7U7-100000360-2', 'BM1A7U8-100000360-2', 'BM1A7U9-100000360-2', 'BM1A7V0-100000360-2', 'BM1A7V1-100000360-2', 'BM1A7V2-100000360-2', 'BM1A7V3-100000360-2', 'BM1A7V4-100000360-2', 'BM1A7V5-100000360-2', 'BM1A6K1-100000411-2', 'BM9A6U9-100001114-1', 'BM0C8Z1-2000164-1', 'BM0C7T2-2000196-1', 'BM0K8V4-200305-1', 'BM0L0A6-200305-1', 'BM9B9X1-200512-1', 'BM9B6X2-200589-1', 'BM9C4K2-200609-1', 'BM9C4K3-200609-1', 'BM9C4K4-200609-1', 'BM9C4K5-200609-1', 'BM9C4L7-200609-1', 'BM9C4L8-200609-1', 'BM9C7W7-200947-1', 'BM9A4C2-201255-1', 'BM9D9V1-201385-1', 'BM9D9V2-201385-1', 'BM9D9V3-201385-1', 'BM9E2H4-201481-1', 'BM9E3W7-201515-3', 'BM9E5U8-201809-1', 'BM9F1H1-201819-3', 'BM9D9V1-201907-2', 'BM9D9V2-201907-2', 'BM9D9V4-201907-2', 'BM9F6Y1-202002-1', 'BM9F6Y2-202002-1', 'BM9F6Y3-202002-1', 'BM9F6Y4-202002-1', 'BM9B4G4-Not Booked', 'BM0C6Z9-Order1', 'BM0C7B3-Order1', 'BM0C7D3-Order1', 'BM0C7F5-Order1', 'BM0C7F6-Order1', 'BM0C7G1-Order1', 'BM0C7Q4-Order1', 'BM0C7U2-Order1', 'BM0C8W6-Order1', 'BM0Q8U1-Order1', 'BM0Q8X7-Order1', 'BM4K4E7-Order1', 'BM9J8U1-Order1', 'BM0C6Z9-Order2', 'BM0C7B3-Order2', 'BM0C7D3-Order2', 'BM0C7F5-Order2', 'BM0C7F6-Order2', 'BM0C7F7-Order2', 'BM0C7G1-Order2', 'BM0C7P6-Order2', 'BM0C7Q2-Order2', 'BM0C7U2-Order2', 'BM0C8I0-Order2', 'BM0C8W6-Order2', 'BM0Q6S3-Order2', 'BM0Q8U1-Order2', 'BM4K4E7-Order2', 'BM9J8U1-Order2']

    batch2 = ['BM9B8R8-2000025', 'BM9F4Z1-2000262', 'BM9G3P5-2000279', 'BM9E9F8-2000485', 'BM9F4X2-2000706', 'BM9G6L5-2000706', 'BM9E4Z8-2000956', 'BM9G1U8-2001775', 'BM9F5U2-2003508', 'BM4H8M5-2003550', 'BM9G8N5-2003550', 'BM9G8G5-2003622', 'BM9L6D8-10210328', 'BM9L6D9-10210328', 'BM9Q5P6-10210580', 'BM9T4N8-10210580', 'BM9X7E1-10210580', 'BM9S5M2-10210696', 'BM9V3M1-10210696', 'BM00008-10210780', 'BM9P8D8-10210780', 'BM9Y8U9-10210780', 'BM9Q1T8-10211030', 'BM3B8G1-10610052', 'BM0O7G3-10910112', 'BM9M5D3-11410018', 'BM9M5D3-11410025', 'BM9K1B2-99999036', 'BM9K1B4-99999036', 'BM9G8G5-99999038', 'BM4H8M5-99999057', 'BM9G8G5-210200086', 'BM9K1B4-210200096']

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
      current_row = product_sku + '-' + order_number
      if sales_order.present? && batch1.include?(current_row)

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
            quantity_mismatch.push(current_row)
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

          new_row_total = order_row.total_selling_price.to_f.round(2)
          new_row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)

          if (new_row_total == bible_order_row_total) && (new_row_total_with_tax == bible_order_row_total_with_tax)
            if updated_orders_with_matching_total_with_tax.include?(current_row)
              repeating_rows.push(current_row)
              repeating_matching_rows_total = repeating_matching_rows_total + new_row_total_with_tax
              repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
            else
              i = i + 1
              puts 'Matched order count', i
              updated_orders_with_matching_total_with_tax.push(current_row)
              updated_orders_total_with_tax = updated_orders_total_with_tax + new_row_total_with_tax
              bible_total_with_tax = bible_total_with_tax + bible_order_row_total_with_tax
            end
          elsif (new_row_total != bible_order_row_total) || (new_row_total_with_tax != bible_order_row_total_with_tax)
            j = j + 1
            puts 'Mismatched order count', j
            updated_orders_with_matching_total.push(current_row)
            updated_orders_total = updated_orders_total + new_row_total_with_tax
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
    puts 'repeating_rows', repeating_rows

    puts 'COMPLETELY MATCHED UPDATED ORDERS', updated_orders_with_matching_total_with_tax, updated_orders_with_matching_total_with_tax.count
    puts 'Totals(sprint/bible)', updated_orders_total_with_tax.to_f, bible_total_with_tax.to_f
    puts "QMismatch", quantity_mismatch
    puts "MATCHED", i
    puts "MISMATCH", j
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
