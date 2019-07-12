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

  def alias_with_po_total
    column_headers = ['Company Alias', 'Company', 'Order Status', 'Order Total']
    model = PurchaseOrder
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.find_each(batch_size: 1000) do |po|
        supplier_alias = po.supplier.present? ? po.supplier.account.name : po.inquiry.inquiry_number.to_s + po.po_number.to_s
        supplier_name = po.supplier.present? ? po.supplier.name : po.inquiry.inquiry_number.to_s + po.po_number.to_s
        po_total = po.converted_total.to_s
        writer << [supplier_alias, supplier_name, po_total]
      end
    end

    fetch_csv('alias_with_po_total.csv', csv_data)
  end

  def alias_with_order_total
    column_headers = ['Company Alias', 'Company', 'Order Status', 'Order Total']
    model = Company
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.acts_as_customer.includes(:account).all.order(name: :asc).find_each(batch_size: 500) do |company|
        company.inquiries.each do |company_inquiry|
          company_inquiry.sales_orders.remote_approved.each do |order|
            company_alias = company.account.name
            company_name = company.name
            order_status = order.status
            order_total = order.converted_total.to_s
            writer << [company_alias, company_name, order_status, order_total]
          end
        end
      end
    end

    fetch_csv('alias_with_order_total.csv', csv_data)
  end

  def so_dump
    columns = [
        'Inquiry Number',
        'Order Number',
        'Old Order Number',
        'AE Parent Order Number',
        'Order Date',
        'MIS Date',
        'Company Name',
        'Order Net Amount',
        'Order Tax Amount',
        'Sprint Status',
        'SAP Order Status',
        'Quote Type',
        'Opportunity Type'
    ]

    model = SalesOrder
    csv_data = CSV.generate(write_headers: true, headers: columns) do |writer|
      model.remote_approved.order(mis_date: :desc).find_each(batch_size: 2000) do |sales_order|
        inquiry = sales_order.inquiry
        writer << [
            inquiry.try(:inquiry_number) || '',
            sales_order.is_credit_note_entry ? SalesOrder.where(id: sales_order.parent_id).first.order_number : sales_order.order_number,
            sales_order.old_order_number.present? ? sales_order.old_order_number : '',
            sales_order.is_credit_note_entry ? sales_order.order_number : '',
            sales_order.created_at.to_date.to_s,
            sales_order.mis_date.present? ? sales_order.mis_date.to_date.to_s : '-',
            inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : '',
            (sales_order.calculated_total == 0 || sales_order.calculated_total == nil) ? 0 : '%.2f' % (sales_order.calculated_total),
            ('%.2f' % sales_order.calculated_total_tax if sales_order.inquiry.present?),
            sales_order.status,
            sales_order.remote_status,
            inquiry.try(:quote_category) || '',
            inquiry.try(:opportunity_type) || ''
        ]
      end
    end

    fetch_csv('sprint_sales_orders_export_new.csv', csv_data)
  end

  def company_wise_po_dump
    columns = ['Customer PO No.', 'Inquiry no.', 'Supplier PO no', 'Supplier name', 'Supplier PO date', 'Supplier PO status']
    inquiries = Inquiry.where(company_id: [8227, 8283])
    csv_data = CSV.generate(write_headers: true, headers: columns) do |writer|
      inquiries.each do |inquiry|
        PurchaseOrder.where(inquiry_id: inquiry.id).each do |po|
          writer << [inquiry.customer_po_number, inquiry.inquiry_number, po.po_number, po.supplier.name, format_succinct_date(po.created_at), po.status]
        end
      end
    end
    fetch_csv('company_wise_po_dump1.csv', csv_data)
  end

  def fetch_sez_addresses
    address_ids = Inquiry.where(is_sez: true).pluck(:billing_address_id)
    columns = ['Address ID', 'Company Name']
    records = Address.where(id: address_ids)
    csv_data = CSV.generate(write_headers: true, headers: columns) do |writer|
      records.each do |record|
        writer << [record.id, record.name]
      end
    end
    # fetch_csv('sez_addresses.csv', csv_data)
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


  def update_company_and_alias
    issue_in_update = []
    issue_in_account_update = []

    not_in_sap = []
    account_not_in_sap = []
    i = 1
    missing_companies = []
    missing_account = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_accounts.csv', 'seed_files_3')
    service.loop(100) do |x|
      puts '********************** ITERATION ***************************', i
      i = i + 1
      # next if i < 300
      next if x.get_column('Duplicate Company Name? - Final (Yes / No)') == 'Yes'

      company = Company.acts_as_customer.find_by_name(x.get_column('Company Name').to_s)

      if company.blank?
        probable_companies = Company.acts_as_customer.where('companies.name like ?', "%#{x.get_column('Company Name')}%")
        probable_companies.each do |probable_company|
          if probable_company.name.squish == x.get_column('Company Name').to_s
            company = probable_company
            break
          end
        end
      end

      # updates company
      if company.present?
        remote_uid = ::Resources::BusinessPartner.custom_find(company.name, company.is_supplier? ? 'cSupplier' : 'cCustomer')
        remote_uid.present? ? company.update_attributes(remote_uid: remote_uid) : company.update_attributes(remote_uid: nil)

        company.name = x.get_column('Corrected Company Name - Final')
        company.save(validate: false)
        if company.remote_uid.blank?
          begin
            remote_uid = ::Resources::BusinessPartner.create(company)
          rescue
            not_in_sap.push(x.get_column('Company Name'))
          else
            company.update_attributes(remote_uid: remote_uid) if remote_uid.present?
          ensure
            # ensure that this code always runs, no matter what
            # does not change the final value of the block
          end
        else
          begin
            ::Resources::BusinessPartner.temp_update(company.remote_uid, company)
          rescue StandardError => e
            puts '--------------------------------- C UPDATE Error ------------------------------------', e.inspect
            issue_in_update.push(x.get_column('Company Name'))
          end
        end

        # updates account
        if company.account.present?
          new_account = Account.find_by_name(x.get_column('Corrected Alias Name - Final').to_s)

          if new_account.present?
            company.account = new_account
            company.save(validate: false)
          else
            account = company.account
            account.name = x.get_column('Corrected Alias Name - Final').to_s
            account.save(validate: false)
          end
          account = company.account
          if account.remote_uid.present?
            begin
              ::Resources::BusinessPartnerGroup.update(account.remote_uid, account)
            rescue StandardError => e
              puts '--------------------------------- A UPDATE Error ------------------------------------', e.inspect
              issue_in_account_update.push(x.get_column('Company Name'))
            end
          else
            begin
              remote_uid = ::Resources::BusinessPartnerGroup.create(account)
            rescue
              account_not_in_sap.push(x.get_column('Company Name'))
            else
              account.update_attributes(remote_uid: remote_uid) if remote_uid.present?
            end
          end
        else
          missing_account.push(x.get_column('Company Name'))
        end
      else
        missing_companies.push(x.get_column('Company Name'))
      end
    end
    puts '***************************** Missing Companies *******************************', missing_companies
    puts '****************************** ISSUE IN COMPANY UPDATE *********************', issue_in_update
    puts '***************************** Missing Accounts *******************************', missing_account
    puts '*************************** ISSUE IN ACC UPDATE ********************************', issue_in_account_update
    puts '**************************** C not in SAP ********************************', not_in_sap
    puts '************************ A not in SAP *****************************', account_not_in_sap
  end

  def update_company_and_alias_new
    company_not_synced_in_sap = []
    issue_in_account_sync = []
    missing_companies = []
    missing_account = []
    different_account_name = []

    i = 1
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_accounts.csv', 'seed_files_3')
    service.loop(nil) do |x|
      puts '********************** ITERATION ***************************', i
      i = i + 1
      # next if i <= 300
      next if x.get_column('Duplicate Company Name? - Final (Yes / No)') == 'Yes'

      company = Company.acts_as_customer.find_by_name(x.get_column('Company Name').to_s)

      if company.blank?
        probable_companies = Company.acts_as_customer.where('companies.name like ?', "%#{x.get_column('Company Name')}%")
        probable_companies.each do |probable_company|
          if probable_company.name.downcase.squish == x.get_column('Company Name').to_s.downcase
            company = probable_company
            break
          end
        end
      end

      # updates company
      if company.present?
        company.name = x.get_column('Corrected Company Name - Final')
        company.save(validate: false)
        begin
          company.save_and_sync
        rescue
          company_not_synced_in_sap.push(x.get_column('Company Name'))
        end

        # updates account
        if company.account.present?
          new_account = Account.find_by_name(x.get_column('Corrected Alias Name - Final').to_s)

          if new_account.present?
            company.account = new_account
            company.save(validate: false)
          else
            old_account_name = company.account.name.downcase
            new_account_name = x.get_column('Corrected Alias Name - Final').to_s.downcase
            if old_account_name.include?(new_account_name) || new_account_name.include?(old_account_name)
              account = company.account
              account.name = x.get_column('Corrected Alias Name - Final').to_s
              account.save(validate: false)
              company.save(validate: false)
            else
              different_account_name.push(x.get_column('Corrected Alias Name - Final').to_s)
            end
          end

          begin
            account = company.account
            account.save_and_sync
          rescue StandardError => e
            issue_in_account_sync.push(x.get_column('Company Name'))
          end
        else
          missing_account.push(x.get_column('Company Name'))
        end
      else
        missing_companies.push(x.get_column('Company Name'))
      end
    end
    puts '***************************** Missing Companies *******************************', missing_companies
    puts '****************************** ISSUE IN COMPANY SYNC *********************', company_not_synced_in_sap
    puts '***************************** Missing Accounts *******************************', missing_account
    puts '*************************** ISSUE IN ACC SYNC ********************************', issue_in_account_sync
    puts '**************************** DIFFERENT ACCOUNT NAME *****************************', different_account_name
  end

  def check_new_company_names_and_accounts
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_accounts.csv', 'seed_files_3')
    updated_correctly = 1
    to_be_checked = []
    service.loop(nil) do |x|
      next if x.get_column('Duplicate Company Name? - Final (Yes / No)') == 'Yes'
      # old_company = Company.acts_as_customer.where(name: x.get_column('Company Name')).last
      new_company = Company.acts_as_customer.where(name: x.get_column('Corrected Company Name - Final')).last
      # if (old_company.present? && new_company.present? && old_company.id == new_company.id) ||
      if new_company.present? && new_company.account.name == x.get_column('Corrected Alias Name - Final').to_s && new_company.name == x.get_column('Corrected Company Name - Final').to_s
        puts '*************Correct******************', updated_correctly
        updated_correctly = updated_correctly + 1
      else
        to_be_checked.push(x.get_column('Company Name'))
      end
    end
    puts 'UPDATED CORRECTLY', updated_correctly
    puts 'TO BE CHECKED', to_be_checked, to_be_checked.count
  end

  def check_missing_companies
    missing_companies = []
    missing_in_sprint = []

    service = Services::Shared::Spreadsheets::CsvImporter.new('company_accounts.csv', 'seed_files_3')
    service.loop(nil) do |x|
      company = Company.acts_as_customer.where(name: x.get_column('Company Name')).last
      if company.present?
        remote_uid = ::Resources::BusinessPartner.custom_find(company.name, company.is_supplier? ? 'cSupplier' : 'cCustomer')
        if remote_uid.blank?
          missing_companies.push(x.get_column('Company Name'))
        end
      else
        missing_in_sprint.push(x.get_column('Company Name'))
      end
    end
    puts 'Missing in sprint', missing_in_sprint
    puts 'Missing Companies', missing_companies
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

  def complete_mismatch_sheet
    column_headers = ['Inside Sales Name', 'Client Order Date', 'Price Currency', 'Document Rate', 'Magento Company Name', 'Company Alias', 'Inquiry Number', 'So #', 'Order Date', 'Bm #', 'Order Qty', 'Unit Selling Price', 'Freight', 'Tax Type', 'Tax Rate', 'Tax Amount', 'Total Selling Price', 'Total Landed Cost', 'Unit cost price', 'Margin', 'Margin (In %)', 'Kit', 'AE', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax', 'Different Tax Rate']
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
        puts '********************************* ITERATION ************************************', iteration
        iteration = iteration + 1
        is_adjustment_entry = 'No'
        tax_rate_different = 'No'
        order_number = x.get_column('So #')
        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        next if bible_order_row_total.to_f.zero? || x.get_column('Inquiry Number').to_i != 25329

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

        if bible_order_row_total.negative?
          ae_sales_order = SalesOrder.where(parent_id: sales_order.id, is_credit_note_entry: true).first
          sales_order = ae_sales_order
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

            if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))
              tax_rate_percentage = x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_d
            else
              tax_rate_percentage = x.get_column('Tax Rate').split('%')[0].to_d
            end
            tax_amount = ((tax_rate_percentage.to_f / 100) * row_total).to_f.round(2)

            if ((row_total != bible_order_row_total) || (order_row.total_tax.to_f.round(2) != tax_amount)) &&
                (row_total - bible_order_row_total).abs > 1

              if x.get_column('Tax Rate').present? && x.get_column('Tax Type').present? &&
                  x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_f != x.get_column('Tax Rate').split('%')[0].to_f
                tax_rate_different = 'Yes'
              end

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
                           row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, tax_rate_different]
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
                           row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, tax_rate_different]
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
      puts 'AE ENTRIES', ae_entries, ae_entries.count
    end

    fetch_csv('current_mismatch1.csv', csv_data)
  end

  def update_non_kit_non_ae_except_zero_tsp
    # mismatch_before_batch2
    # mismatch_sheet
    service = Services::Shared::Spreadsheets::CsvImporter.new('mismatch_sheet002.csv', 'seed_files_3')
    corrected = []
    tax_mismatch = []
    repeating_rows = []
    quantity_mismatch = []
    tax_rate_difference = []
    is_in_qr = []

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

    batch2 = ['BM0C7B2-200046', 'BM0J2N5-200046', 'BM1A6Q7-200056', 'BM0I0R4-200105', 'BM0C7K0-200120', 'BM0C8Y9-200128', 'BM9B3N8-200151', 'BM0C7B2-200162', 'BM0L8R9-200167', 'BM1B0W4-200169', 'BM1B0W5-200169', 'BM1B0W6-200169', 'BM0O4A9-200196', 'BM0C7C6-200199', 'BM0C7F5-200199', 'BM0C7R0-200199', 'BM0C8G9-200199', 'BM0C8T7-200199', 'BM0C9D6-200199', 'BM0C9D7-200199', 'BM0C9D8-200199', 'BM0C9D9-200199', 'BM0L8M4-200199', 'BM0Z1D0-200199', 'BM0Z1D2-200199', 'BM1A5Z3-200199', 'BM1A5Z4-200199', 'BM1A6O4-200199', 'BM1A6O5-200199', 'BM1A6O6-200199', 'BM1A8B5-200199', 'BM1A8B7-200199', 'BM1A5Z0-200202', 'BM1A5Z1-200202', 'BM1A6S3-200202', 'BM1A6S5-200202', 'BM1A6T1-200202', 'BM1A6U5-200202', 'BM1A6U6-200202', 'BM1A6W1-200202', 'BM1A6W2-200202', 'BM1A6W3-200202', 'BM1A6W4-200202', 'BM1A6W5-200202', 'BM1A6W6-200202', 'BM1A6W9-200202', 'BM1A6X0-200202', 'BM1A6X1-200202', 'BM1A6X7-200202', 'BM1A6X8-200202', 'BM1A6Y0-200202', 'BM1A6Y5-200202', 'BM1A6Y6-200202', 'BM1A6Y7-200202', 'BM1A6Z0-200202', 'BM1A6Z1-200202', 'BM1A6Z2-200202', 'BM1A6Z3-200202', 'BM1A6Z4-200202', 'BM1A6Z6-200202', 'BM1A6Z7-200202', 'BM1A6Z8-200202', 'BM1A6Z9-200202', 'BM1A7A0-200202', 'BM1A7A2-200202', 'BM1A7A3-200202', 'BM0C7B2-200208', 'BM0C7C6-200208', 'BM0C7D5-200208', 'BM0C7H9-200208', 'BM0C7I9-200208', 'BM0C7M1-200208', 'BM0C7Q6-200208', 'BM0C7R5-200208', 'BM0C7S1-200208', 'BM0C7T8-200208', 'BM0C8Z1-200208', 'BM0C9B1-200208', 'BM0C9B3-200208', 'BM0L8L7-200208', 'BM1A4B3-200208', 'BM1A6A0-200208', 'BM1A6A3-200208', 'BM1A6M9-200208', 'BM1A6N6-200208', 'BM1A7H7-200208', 'BM1A7I4-200208', 'BM1A7J9-200208', 'BM1A7K5-200208', 'BM1A7N6-200208', 'BM1A7N8-200208', 'BM1A7Q8-200208', 'BM1A7W3-200208', 'BM1A7W4-200208', 'BM1A7W5-200208', 'BM1A7W6-200208', 'BM1A7X1-200208', 'BM1A7X2-200208', 'BM1A7X3-200208', 'BM1A7X4-200208', 'BM1A7X6-200208', 'BM1A7X7-200208', 'BM1A7X8-200208', 'BM1A7X9-200208', 'BM1A7Y2-200208', 'BM1A7Y3-200208', 'BM1A7Y4-200208', 'BM1A7Y5-200208', 'BM1A7Y6-200208', 'BM1A7Y7-200208', 'BM1A7Y8-200208', 'BM1A7Y9-200208', 'BM1A7Z1-200208', 'BM1A7Z2-200208', 'BM1A7Z3-200208', 'BM1A7Z4-200208', 'BM1A7Z5-200208', 'BM1A7Z6-200208', 'BM1A7Z7-200208', 'BM1A7Z8-200208', 'BM1A7Z9-200208', 'BM1A8A0-200208', 'BM1A8A1-200208', 'BM1A8A2-200208', 'BM1A8A3-200208', 'BM1A8A4-200208', 'BM1A8B2-200208', 'BM1A8B3-200208', 'BM1A8D9-200208', 'BM1A8E0-200208', 'BM1A8E2-200208', 'BM1A8E4-200208', 'BM1A8E5-200208', 'BM1A8E6-200208', 'BM1A8E7-200208', 'BM1A8E8-200208', 'BM1A8G4-200208', 'BM1A8G5-200208', 'BM1A8G6-200208', 'BM1A8G7-200208', 'BM1A8G8-200208', 'BM0C7A0-200213', 'BM0C7B0-200213', 'BM0C7B1-200213', 'BM0C7B2-200213', 'BM0C7B8-200213', 'BM0C7C9-200213', 'BM0C7D8-200213', 'BM0C7F8-200213', 'BM0C7G7-200213', 'BM0C7I4-200213', 'BM0C7T5-200213', 'BM0C7U2-200213', 'BM0C7V4-200213', 'BM0C8G8-200213', 'BM0C8H6-200213', 'BM0C8S9-200213', 'BM0C8U4-200213', 'BM0C8Y8-200213', 'BM0C9F8-200213', 'BM0C9G0-200213', 'BM0C9G1-200213', 'BM1A7Z0-200213', 'BM1A8K9-200213', 'BM1A8L0-200213', 'BM1A8L1-200213', 'BM1A8L3-200213', 'BM1A8L4-200213', 'BM1A8L5-200213', 'BM1A8L6-200213', 'BM1A8L7-200213', 'BM1A8F0-200226', 'BM1A8F1-200226', 'BM0C7G0-200228', 'BM0C8D6-200228', 'BM1A3W6-200228', 'BM0Z1F5-200234', 'BM1A8X2-200237', 'BM9C3Z9-200591', 'BM9C4A1-200591', 'BM9A9A3-200665', 'BM9C4W8-200726', 'BM9C4W9-200726', 'BM9C4X1-200726', 'BM0O4O6-200769', 'BM0O4O7-200769', 'BM0O4P1-200769', 'BM0O4P3-200769', 'BM0O4Q3-200769', 'BM0O4Q4-200769', 'BM0O4Q5-200769', 'BM0O4S6-200769', 'BM0O4T1-200769', 'BM0O4T3-200769', 'BM0O4T7-200769', 'BM9A4E4-200769', 'BM0O3Y7-200770', 'BM0O4E4-200770', 'BM0O4E6-200770', 'BM0O4E7-200770', 'BM0O4F1-200770', 'BM0O4F3-200770', 'BM0O4F4-200770', 'BM0O4F7-200770', 'BM0O4F9-200770', 'BM0O4G8-200770', 'BM0O4G9-200770', 'BM0O4H6-200770', 'BM0O4I5-200770', 'BM0O4I7-200770', 'BM0O4J5-200770', 'BM0O4J6-200770', 'BM0O4J7-200770', 'BM0O4J8-200770', 'BM0O4K0-200770', 'BM0O4K1-200770', 'BM0O4K2-200770', 'BM0O4K6-200770', 'BM0O4L8-200770', 'BM0O4M0-200770', 'BM0O4M1-200770', 'BM0O4V1-200770', 'BM9A3R1-200770', 'BM9A3R2-200770', 'BM9A4Y2-200770', 'BM0O4V2-200818', 'BM0O4V4-200818', 'BM9C8D8-200914', 'BM9C8D9-200914', 'BM1A4X2-200942', 'BM9A5Y9-200956', 'BM9B7J7-201065', 'BM9D2N1-201147', 'BM9D2N2-201147', 'BM9A8T4-201201', 'BM9D5V6-201204', 'BM9D5W1-201204', 'BM9D5W2-201204', 'BM9D5W3-201204', 'BM9D5W4-201204', 'BM9D6N6-201204', 'BM9D6V5-201205', 'BM9D6V6-201205', 'BM9D6V7-201219', 'BM9D6Z7-201235', 'BM9D8X2-201306', 'BM9D8X3-201306', 'BM9D8X4-201306', 'BM9D8X5-201306', 'BM9D8X6-201306', 'BM9D8X7-201306', 'BM9D8X8-201306', 'BM9D8X9-201306', 'BM9D8Y1-201306', 'BM9D8Y2-201306', 'BM9D8Y3-201306', 'BM9D8Y4-201306', 'BM9D8Y5-201306', 'BM9D8Y6-201306', 'BM9D8Y7-201306', 'BM9D8Y8-201306', 'BM9D8V4-201321', 'BM9E3G3-201503', 'BM9E2T2-201516', 'BM9E2T3-201516', 'BM0K9A4-201601', 'BM9C8Y1-201631', 'BM9D9Q3-201705', 'BM9C8K5-201830', 'BM9F4C9-201877', 'BM9F4C7-201889', 'BM9E1Y3-201931', 'BM1A0E4-201996', 'BM9E5S4-202048', 'BM9E8P5-202083', 'BM0Y8Z1-202085', 'BM9E4Z8-2000956', 'BM1A4X2-2001311', 'BM9G1U8-2001775', 'BM9L6D8-10210328', 'BM9L6D9-10210328', 'BM9Q5P6-10210580', 'BM9T4N8-10210580', 'BM9X7E1-10210580', 'BM9S5M2-10210696', 'BM9V3M1-10210696', 'BM00008-10210780', 'BM9P8D8-10210780', 'BM9Y8U9-10210780', 'BM9Q1T8-10211030', 'BM0O7G3-10910112', 'BM9M5D3-11410018', 'BM9M5D3-11410025', 'BM9K1B2-99999036', 'BM9K1B4-99999036', 'BM9A3P8-100000130', 'BM9A3P9-100000130', 'BM9A3Q1-100000130', 'BM9A3Q2-100000130', 'BM9A3Q3-100000130', 'BM9A3Q4-100000130', 'BM1A3U8-100000233', 'BM1A3V0-100000250', 'BM1A3V1-100000250', 'BM1A3V4-100000250', 'BM1A3V5-100000250', 'BM1A3V7-100000250', 'BM1A3V8-100000250', 'BM1A3V9-100000250', 'BM1A3W0-100000250', 'BM1A3W1-100000250', 'BM1A3W2-100000250', 'BM1A4X3-100000250', 'BM1A4S0-100000259', 'BM1A3Q4-100000271', 'BM0C7V1-100000278', 'BM1A3M9-100000283', 'BM1A8Y8-100000294', 'BM1A8Y9-100000294', 'BM1A8Z0-100000294', 'BM1A8Z1-100000294', 'BM1A8Z2-100000294', 'BM1A8Z3-100000294', 'BM1A8Z4-100000294', 'BM1A8Z5-100000294', 'BM1A8Z6-100000294', 'BM1A8Z7-100000294', 'BM1A8Z8-100000294', 'BM1A8Z9-100000294', 'BM1A9A0-100000294', 'BM1A3U7-100000319', 'BM1A8T4-100000328', 'BM1A7W2-100000363', 'BM9A3U7-100000388', 'BM9A3U8-100000388', 'BM9A3U9-100000388', 'BM9A3V1-100000388', 'BM9A3V2-100000388', 'BM9A3V3-100000388', 'BM9A3V4-100000388', 'BM9A3V5-100000388', 'BM9A3V6-100000388', 'BM9A3V7-100000388', 'BM9A3V8-100000388', 'BM9A3V9-100000388', 'BM9A3W1-100000388', 'BM9A3W2-100000388', 'BM9A3W3-100000388', 'BM9A3W4-100000388', 'BM9A3W5-100000388', 'BM9A3W6-100000388', 'BM9A3W7-100000388', 'BM9A3W8-100000388', 'BM9A3W9-100000388', 'BM9A3X1-100000388', 'BM9A3X2-100000388', 'BM9A3X3-100000388', 'BM9A3X4-100000388', 'BM9A3X5-100000388', 'BM9A3X6-100000388', 'BM9A3X7-100000388', 'BM9A3X8-100000388', 'BM9A3X9-100000388', 'BM9A3Y1-100000388', 'BM9A3Y2-100000388', 'BM9A3Y3-100000388', 'BM9A3Y4-100000388', 'BM9A3Y5-100000388', 'BM9A3Y6-100000388', 'BM9A3T4-100000390', 'BM9A3T5-100000390', 'BM1A7N2-100000400', 'BM1A6L3-100000403', 'BM1A6Q0-100000403', 'BM1A7N0-100000404', 'BM1A7P0-100000406', 'BM1A7N3-100000408', 'BM1A7T8-100000409', 'BM1A6M2-100000415', 'BM1A6M3-100000415', 'BM1A6L6-100000416', 'BM1A7O4-100000427', 'BM1A7O5-100000427', 'BM1A7O6-100000427', 'BM1A7O7-100000427', 'BM1A7O8-100000427', 'BM1A7O9-100000427', 'BM1A6H8-100000431', 'BM1A7K2-100000435', 'BM1A7H1-100000472', 'BM1A7P3-100000472', 'BM1A7I6-100000482', 'BM1A7H2-100000483', 'BM1A7H3-100000483', 'BM0O3Z8-100000491', 'BM1A6I7-100000493', 'BM1A6A7-100000500', 'BM1A6J7-100000506', 'BM1A6N3-100000506', 'BM1A4P5-100000510', 'BM1A6C0-100000513', 'BM1A6C1-100000513', 'BM1A6C2-100000513', 'BM1A7L6-100000570', 'BM1A4Q7-100000585', 'BM1A7S4-100000586', 'BM1A4P0-100000593', 'BM1A6V6-100000593', 'BM1A4Q9-100000598', 'BM1A7H6-100000604', 'BM1A6E4-100000608', 'BM1A6Q2-100000608', 'BM1A8O4-100000613', 'BM1A8O5-100000613', 'BM1A8O6-100000613', 'BM1A8O7-100000613', 'BM1A4Q6-100000622', 'BM1A3M4-100000623', 'BM1A3M5-100000623', 'BM1A3M6-100000623', 'BM1A8M3-100000623', 'BM1A7N0-100000625', 'BM1A7V7-100000629', 'BM1A7V8-100000629', 'BM1A7V9-100000629', 'BM1A7W0-100000629', 'BM1A7W1-100000629', 'BM1A5Z5-100000633', 'BM1A7N0-100000647', 'BM0C7U2-100000649', 'BM0C7F6-100000677', 'BM1A9T2-100000742', 'BM1A6N5-100000790', 'BM1A7N0-100000809', 'BM1A7N0-100000812', 'BM1A7N0-100000814', 'BM1A8E9-100000835', 'BM1A8F2-100000839', 'BM1A8F4-100000839', 'BM1A8F5-100000839', 'BM1A8F6-100000839', 'BM1A6G1-100000841', 'BM1A6G2-100000841', 'BM1A6G3-100000841', 'BM1A6G4-100000841', 'BM1A6G5-100000841', 'BM1A6G6-100000841', 'BM1A8V6-100000858', 'BM1A8V7-100000858', 'BM0C7F5-100000860', 'BM1A9A4-100000873', 'BM1A9A5-100000873', 'BM1A9A6-100000873', 'BM1A9A7-100000873', 'BM9A4J5-100000879', 'BM9A4J6-100000879', 'BM9A4J7-100000879', 'BM9A4J8-100000879', 'BM9A4J9-100000879', 'BM9A4K1-100000879', 'BM9A4K2-100000879', 'BM9A4K3-100000879', 'BM9A4K4-100000879', 'BM0O7Z5-100000927', 'BM1A7M9-100000943', 'BM1A6M5-100000945', 'BM1A6A3-100000947', 'BM9A7W5-100001152', 'BM0O4E2-100001406', 'BM1A8J0-100001408', 'BM1A6K4-100001411', 'BM1A6K5-100001411', 'BM1A6K6-100001411', 'BM1A6K9-100001411', 'BM1A6L1-100001411', 'BM1A6L4-100001411', 'BM1A6L5-100001411', 'BM1A6M7-100001411', 'BM1A6M8-100001411', 'BM1A6P6-100001415', 'BM1A6P7-100001415', 'BM1A6P8-100001415', 'BM9K1B4-210200096', 'BM1A3Y3-100000221-2', 'BM1A3Y4-100000221-2', 'BM0L8K2-100000480-1', 'BM1A5T7-100000554-1', 'BM1A5T8-100000554-1', 'BM1A5T9-100000554-1', 'BM1A5U0-100000554-1', 'BM1B1L9-100000705-1', 'BM1A4W9-100000859-2', 'BM0Y9N4-100000926-1', 'BM0O3Y7-100000960-1', 'BM0O4F4-100000960-1', 'BM0O4F5-100000960-1', 'BM0O4G2-100000960-1', 'BM0O4G7-100000960-1', 'BM0O4G8-100000960-1', 'BM0O4G9-100000960-1', 'BM0O4I3-100000960-1', 'BM0O4J5-100000960-1', 'BM0O4J6-100000960-1', 'BM0O4J9-100000960-1', 'BM0O4K0-100000960-1', 'BM0O4K1-100000960-1', 'BM0O4K2-100000960-1', 'BM0O4K5-100000960-1', 'BM0O4L2-100000960-1', 'BM0O4L4-100000960-1', 'BM0O4O5-100000960-1', 'BM0O4O7-100000960-1', 'BM0O4P3-100000960-1', 'BM0O4Q3-100000960-1', 'BM0O4Q5-100000960-1', 'BM0O4R0-100000960-1', 'BM0O4R2-100000960-1', 'BM0O4R6-100000960-1', 'BM0O4S3-100000960-1', 'BM0O4S6-100000960-1', 'BM0O4T1-100000960-1', 'BM0O4T3-100000960-1', 'BM0O4T4-100000960-1', 'BM0O4T7-100000960-1', 'BM0O4T9-100000960-1', 'BM0O4U3-100000960-1', 'BM0O4U4-100000960-1', 'BM0O4V1-100000960-1', 'BM0O4V2-100000960-1', 'BM0O4V3-100000960-1', 'BM0O4V4-100000960-1', 'BM0O4B2-100001175-1', 'BM0C7B2-200046-1', 'BM0J2N5-200046-1', 'BM9B4Y8-200080-1', 'BM1Z9R4-200184-1', 'BM9B3P1-200275-2', 'BM9B6L7-200275-2', 'BM9B6L8-200275-2', 'BM9B6L9-200275-2', 'BM9C4K1-200609-1', 'BM1G1U3-200614-3', 'BM3C8L6-200614-3', 'BM9B4A5-200614-3', 'BM9B4A6-200614-3', 'BM9B4A7-200614-3', 'BM9B4A8-200614-3', 'BM9B4B2-200614-3', 'BM9B4B3-200614-3', 'BM9B4B4-200614-3', 'BM9B4B5-200614-3', 'BM9B4B8-200614-3', 'BM9B4B9-200614-3', 'BM9B4C2-200614-3', 'BM9B4C3-200614-3', 'BM9B4C4-200614-3', 'BM9B4C5-200614-3', 'BM9B4C6-200614-3', 'BM9B4C7-200614-3', 'BM9B4C8-200614-3', 'BM9B4R1-200614-3', 'BM9B4R2-200614-3', 'BM9B4X4-200614-3', 'BM9B4X5-200614-3', 'BM9C1B5-200614-3', 'BM9C1B6-200614-3', 'BM9C1B7-200614-3', 'BM9C1B8-200614-3', 'BM9C1B9-200614-3', 'BM9C1C1-200614-3', 'BM9C1C3-200614-3', 'BM9C5C1-200614-3', 'BME3X5J-200614-3', 'BM9C9Z4-200922-1', 'BM9D4B6-201083-1', 'BM9D6S6-201256-1', 'BM9D5V7-201283-1', 'BM0O4V3-201690-2', 'BM9D6S6-201898-2', 'BM9F9A7-202023-1', 'BM9G1T2-202052-3', 'BM0C8Y9-Order2', 'BM0C9M9-Order2']

    duplicate_skus = ['BM0P0P2 - 200227', 'BM1A4X2 - 2001311', 'BM1A7S9 - 100000536', 'BM0Y9N6 - 10041', 'BM1B2L9 - 10094', 'BM9A5W9 - 10140', 'BM9C7Y1 - 10016', 'BM9C7Y1 - 10017', 'BM9C7Y1 - 10018', 'BM9C7Y1 - 10019']

    batch3 = ['BM9L6D8-10210128', 'BM9L6D9-10210128', 'BM9Q1T8-10211012', 'BM0O7G3-10910110', 'BM9E4Z8-10210566', 'BM9Q5P6-10210696', 'BM9T4N8-10210696', 'BM9X7E1-10210696']
    # make new quote for batch3
    # 'BM0Y9N6-100000352-1', 'BM9A5W9-100001115-1', 'BM9C7Y1-201020-1'] ?

    need_quote_revision = ['17138-BM9K5N6-2003236', '10131-BM1A3S7-2003612', '10763-BM9G8F3-2003622', '10763-BM9G8G5-2003622', '10960-BM9H5P9-2003627', '10960-BM9H5Q1-2003627', '11032-BM9C4Z8-2003629', '10897-BM9G8E7-2003636', '12624-BM9G1U8-2003641', '14277-BM9H5P9-2003645', '14618-BM9H5Q1-2003646', '15310-BM9J8D5-2003653', '16951-BM1A4X6-2003665', '17125-BM0K8Y0-2003668', '11447-BM9E8Q1-2003671', '17165-BM9M4Z3-2003672', '17440-BM9E5Q4-2003681', '10346-BM9C3W3-2003707', '16329-BM9L8Y9-2003710', '16550-BM0W7M7-2003712', '16550-BM9M1E1-2003712', '17147-BM9G5K1-2003714', '10386-BM9G8E5-10200024', '19971-BM9J5R2-10210212', '20597-BM9P4D1-10210264', '19788-BM9T2N5-10210303', '15029-BM9L6D8-10210328', '15029-BM9L6D9-10210328', '7407-BM9E4Z8-10210566', '7407-BM9E5A2-10210566', '7407-BM9E7Z3-10210566', '7407-BM9E7Z4-10210566', '7407-BM9E7Z5-10210566', '19523-BM9T4Z9-10210677', '19523-BM9U3A9-10210677', '19523-BM9U5B5-10210677', '19523-BM9V4M5-10210677', '19523-BM9V9D5-10210677', '19523-BM9W3C4-10210677', '20975-BM9Q5P6-10210696', '20975-BM9S5M2-10210696', '20975-BM9T4N8-10210696', '20975-BM9V3M1-10210696', '20975-BM9X7E1-10210696', '21455-BM9P5T8-10210771', '25329-BM00008-10210780', '25329-BM9P8D8-10210780', '25329-BM9Y8U9-10210780', '26121-BM9M9Q3-10210831', '20973-BM9P4U7-10210846', '27692-BM9Q1T8-10211030', '27158-BM9Q2R7-10211050', '27158-BM9S9A3-10211050', '25880-BM9K2L2-10211112', '25880-BM0K9T2-10211124', '25880-BM9Q2N3-10211124', '25880-BM9V5Z2-10211124', '30034-BM9N0I0-10211550', '30035-BM9E3D0-10211553', '30037-BM9N0I0-10211560', '30040-BM9U4X1-10211561', '30041-BM9J9Z0-10211563', '30042-BM9U4X1-10211564', '30045-BM9N0I0-10211566', '30083-BM9U4X1-10211569', '30098-BM9E3D0-10211572', '25373-BM9M9V9-10212228', '26226-BM9P9A1-10212364', '18352-BM1A8F3-10300052', '18352-BM1A8F5-10300052', '18352-BM1A8F6-10300052', '18352-BM9E5M5-10300052', '18352-BM1A8F3-10300067', '18352-BM1A8F5-10300067', '18352-BM1A8F6-10300067', '10491-BM9E9F8-10610009', '18742-BM4H8P3-10610013', '18742-BM4H8P3-10610014', '18742-BM4H8P3-10610060', '18352-BM1A8F3-10610090', '18352-BM1A8F4-10610090', '18352-BM1A8F5-10610090', '18352-BM9E5M5-10610090', '10491-BM9E9F8-10610147', '18814-BM9N7F8-10610152', '18742-BM4H8P3-10610161', '19412-BM9Q1T5-10610230', '19412-BM9T6B5-10610230', '18742-BM4H8P3-10610260', '21460-BM9T2D8-10610299', '21460-BM9W4M2-10610299', '19717-BM9N3P1-10610302', '25069-BM9D9V3-10610314', '26093-BM9U4S9-10610316', '26093-BM9W5B8-10610316', '26093-BM9U5J7-10610317', '26093-BM9V4Z2-10610317', '26093-BM9U5J7-10610341', '26093-BM9V4Z2-10610341', '26093-BM9W5B8-10610350', '19849-BM4H8M3-10610351', '26093-BM9U4S9-10610355', '26271-BM9Y4Z9-10610362', '18742-BM4H8P3-10610368', '19849-BM1A8F3-10610388', '19717-BM3B8G1-10610389', '27044-BM0C4U7-10610422', '27044-BM0C4U8-10610422', '27044-BM9Q2K3-10610422', '27044-BM9Q2Q1-10610422', '27044-BM9Q3K7-10610422', '27044-BM9Q4C7-10610422', '27044-BM9Q4P8-10610422', '27044-BM9Q5Q2-10610422', '27044-BM9Q6K1-10610422', '27044-BM9Q7U1-10610422', '27044-BM9R2X7-10610422', '27044-BM9R5N6-10610422', '27044-BM9R6K1-10610422', '27044-BM9S1Q5-10610422', '27044-BM9S2X4-10610422', '27044-BM9S4A4-10610422', '27044-BM9T2T4-10610422', '27044-BM9T8D5-10610422', '27044-BM9T8Q2-10610422', '27044-BM9U8Q9-10610422', '27044-BM9V3H1-10610422', '27044-BM9V6B1-10610422', '27044-BM9W3K2-10610422', '27044-BM9W3W7-10610422', '27044-BM9W6T5-10610422', '27044-BM9X1G9-10610422', '27044-BM9X1Y5-10610422', '27044-BM9X5L7-10610422', '27044-BM9X5U1-10610422', '27044-BM9X6E1-10610422', '27044-BM9X7B8-10610422', '27044-BM9X7F1-10610422', '27044-BM9Z3A5-10610422', '27044-BM9Z8E2-10610422', '26318-BM0C7F7-10610427', '25042-BM9L9L4-10610436', '26771-BM00008-10610874', '26771-BM9T8X7-10610874', '26771-BM9V7R3-10610874', '19959-BM0C0T2-10710005', '19959-BM0C7D6-10710005', '25949-BM3B8F7-10910063', '25949-BM9P7M6-10910063', '26122-BM9Q8Q1-10910069', '26122-BM9R1Q6-10910069', '26122-BM9W4A9-10910069', '20916-BM9P4T2-10910073', '21473-BM0K8J5-10910074', '21473-BM9G8G9-10910074', '21473-BM9P7A3-10910074', '21473-BM9S4R6-10910074', '26901-BM0O7G3-10910112', '27946-BM9K7A8-10910139', '20004-BM9P5M7-10910149', '20004-BM9Q8J8-10910149', '20004-BM9R3S5-10910149', '20004-BM9R4W1-10910149', '20004-BM9S6V8-10910149', '20004-BM9T1G9-10910149', '20004-BM9V2N9-10910149', '20004-BM9V4S2-10910149', '20004-BM9W6T1-10910149', '20004-BM9W7Q5-10910149', '20004-BM9X4H5-10910149', '20004-BM9Z5D4-10910149', '20004-BM9Z7C2-10910149', '20004-BM9Z7G7-10910149', '25001-BM9W8D9-11210042', '26644-BM9M5D3-11410025', '27013-BM9M5D3-11410026', '8992-BM9B6V7-99999002', '9383-BM9F4Z1-99999003', '9865-BM9G3P5-99999004', '11407-BM9F4X2-99999007', '11407-BM9G6L5-99999007', '14257-BM9E6D2-99999008', '14257-BM9E6D9-99999008', '14628-BM4H8M5-99999009', '14628-BM9G8E7-99999009', '13846-BM9G8E7-99999011', '12947-BM3X4Y9-99999012', '12947-BM4H8M5-99999012', '15857-BM3X4Z4-99999013', '15857-BM9G8N6-99999013', '14949-BM3X4Z8-99999014', '15780-BM4H8N6-99999015', '15515-BM9L4E7-99999016', '15515-BM9L4E8-99999016', '15515-BM9L4E9-99999016', '15515-BM9L4F1-99999016', '15693-BM9L5K4-99999017', '15693-BM9L5K6-99999017', '18417-BM9N3T4-99999024', '18417-BM9N4A2-99999024', '18715-BM00008-99999025', '18715-BM9H5P9-99999025', '18352-BM1A8F3-99999026', '18352-BM1A8F4-99999026', '18352-BM1A8F5-99999026', '18352-BM1A8F6-99999026', '18352-BM9E5M5-99999026', '10852-BM9J1B9-99999027', '18686-BM9N6G2-99999028', '18453-BMC4J0D-99999029', '18436-BM4H8N6-99999030', '18323-BM9G8F3-99999033', '13035-BM9K1B2-99999036', '13035-BM9K1B4-99999036', '10763-BM9G8F1-99999038', '10763-BM9G8F3-99999038', '10763-BM9G8G5-99999038', '10763-BM9G8H6-99999038', '18218-BM4H8M5-99999039', '18125-BMC7A4H-99999040', '10386-BM9G8E5-99999042', '18039-BM9E9F8-99999043', '17982-BM9H5P9-99999044', '17982-BM9H5Q1-99999044', '18019-BM9H9M5-99999045', '18019-BM9H9M6-99999045', '18019-BM9H9M7-99999045', '14618-BM9H5Q1-99999047', '14277-BM9H5P9-99999048', '11032-BM9C4Z8-99999050', '17721-BM9M6N2-99999051', '17745-BM3B8G1-99999053', '17745-BM4H8M5-99999053', '17745-BM9G8N5-99999053', '17755-BM9F5U2-99999055', '16667-BM9M2S6-99999056', '16667-BM9M2S7-99999056', '16667-BM9M6H7-99999056', '17582-BM4H8M5-99999057', '16320-BM9M6R4-99999058', '17455-BM9M6Q7-99999059', '17282-BM9M5W5-99999060', '17282-BM9M5W6-99999060', '16562-BM9M1N7-99999062', '16562-BM9M1R4-99999062', '16562-BM9M1R6-99999062', '12342-BM9J6T6-99999070', '12204-BM9J5R4-99999071', '12099-BM9F5U2-99999073', '11146-BM4H8M3-99999075', '10831-BM9A4B2-99999076', '10531-BM9E5K4-99999077', '10392-BM9G7Y4-99999078', '8236-BM9D9S2-99999080', '10252-BM9G2K9-99999081', '9597-BM9F8N3-99999082', '9597-BM9F8N5-99999082', '9597-BM9F8N6-99999082', '9597-BM9F8N7-99999082', '9597-BM9F8N8-99999082', '8832-BM9E7G7-99999083', '8946-BM9B8R8-99999086', '10004-BM9G3U2-99999087', '18465-BM3X4Y9-99999089', '16185-BM9L8G8-99999096', '11986-BM9G4Z6-99999098', '9686-BM9G4H2-99999099', '10152-BM9G7V9-210200083', '10763-BM9G8G5-210200086', '14540-BM9F1S6-210200087', '10897-BM9G8E7-210200088', '13035-BM9K1B4-210200096', '12981-BM9K6H1-210200097', '16447-BM4H8O6-210200099', '15366-BM3X5A6-210200104', '6076-BM0K8V4-200305-1', '6076-BM0L0A6-200305-1', '6517-BM9A4C2-201255-1']

    kit = ['BM9P9A1-10212364', 'BM00043-10300070', 'BM9R6D3-10610467']
    except_vat_cst = ['BM9E4Z8-2000956', 'BM1A4X2-2001311', 'BM9G1U8-2001775', 'BM9L6D8-10210328', 'BM9L6D9-10210328', 'BM9Q5P6-10210580', 'BM9T4N8-10210580', 'BM9X7E1-10210580', 'BM9S5M2-10210696', 'BM9V3M1-10210696', 'BM9P7B6-10210736', 'BM00008-10210780', 'BM9P8D8-10210780', 'BM9Y8U9-10210780', 'BM9Q1T8-10211030', 'BM0O7G3-10910112', 'BM9M5D3-11410018', 'BM9M5D3-11410025', 'BM9K1B2-99999036', 'BM9K1B4-99999036', 'BM9K1B4-210200096', 'BM0C8Y9-Order2', 'BM0C9M9-Order2']

    update_correctly = ['7407-BM9E4Z8-2000956', '12780-BM1A4X2-2001311', '12624-BM9G1U8-2001775', '20975-BM9Q5P6-10210580', '20975-BM9T4N8-10210580', '20975-BM9X7E1-10210580', '26252-BM9P7B6-10210736', '27013-BM9M5D3-11410018', 'O-0002-BM0C8Y9-Order2', 'O-0002-BM0C9M9-Order2']

    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      product_sku = x.get_column('Bm #').to_s.upcase
      current_row = product_sku + '-' + order_number

      # next if kit.include?(current_row) || (x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service')))
      # if batch2.include?(current_row) || batch3.include?(current_row)
      # if x.get_column('Abs. Mismatch').to_f < 100000

      if update_correctly.include?(x.get_column('Inquiry Number') + '-' + current_row)
        if need_quote_revision.include?(x.get_column('Inquiry Number') + '-' + current_row)
          is_in_qr.push(x.get_column('Inquiry Number') + '-' + current_row)
        end
        next if need_quote_revision.include?(x.get_column('Inquiry Number') + '-' + current_row)
        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          if order_number == 'Not Booked'
            inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders

            if inquiry_orders.count > 1
              # multiple_not_booked_orders.push(x.get_column('Bm #') + '-' + x.get_column('Order Date') + '-' + x.get_column('So #'))
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
          puts '******************************** ITERATION *******************************', iteration
          iteration = iteration + 1

          bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
          bible_order_tax_total = x.get_column('Tax Amount').to_f
          bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            quote_row = order_row.sales_quote_row

            # .scan(/^\d*(?:\.\d+)?/)[0]
            if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))
              tax_rate_percentage = x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_d
              tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first_or_create!
            else
              tax_rate_percentage = x.get_column('Tax Rate').split('%')[0].to_d
              tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first
            end

            # main
            if x.get_column('Tax Rate').present? && x.get_column('Tax Type').present? && x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_f != x.get_column('Tax Rate').split('%')[0].to_f
              tax_rate_difference.push(current_row)
            end

            quote_row.quantity = x.get_column('Order Qty').to_f
            quote_row.unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.converted_unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.margin_percentage = x.get_column('Margin (In %)').split('%')[0].to_d
            quote_row.tax_rate = tax_rate || nil
            quote_row.tax_type = x.get_column('Tax Type') if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))
            quote_row.legacy_applicable_tax_percentage = tax_rate_percentage.to_d || nil
            quote_row.inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)
            # quote_row.created_at = Date.parse(Date.new(2019,04,01)).strftime('%Y-%m-%d')
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
            tax_amount = ((tax_rate_percentage.to_f / 100) * new_row_total).to_f.round(2)

            if (order_row.total_tax.to_f.round(2) == tax_amount) && (new_row_total == bible_order_row_total)
              if updated_orders_with_matching_total_with_tax.include?(current_row)
                repeating_rows.push(current_row)
                repeating_matching_rows_total = repeating_matching_rows_total + new_row_total_with_tax
                repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
              else
                i = i + 1
                puts 'Matched order count', i
                updated_orders_with_matching_total_with_tax.push(x.get_column('Inquiry Number') + '-' + current_row)
                updated_orders_total_with_tax = updated_orders_total_with_tax + new_row_total_with_tax
                bible_total_with_tax = bible_total_with_tax + bible_order_row_total_with_tax
                corrected.push(x.get_column('Inquiry Number') + '-' + current_row)
              end
            elsif (order_row.total_tax.to_f.round(2) != tax_amount) || (new_row_total != bible_order_row_total)
              j = j + 1
              puts 'Mismatched order count', j
              updated_orders_with_matching_total.push(current_row)
              updated_orders_total = updated_orders_total + new_row_total_with_tax
              bible_total = bible_total + bible_order_row_total_with_tax
              tax_mismatch.push(current_row)
            else
              # binding.pry
            end
          else
            # add missing skus in sprint
          end
        else
          # add missing orders in sprint
        end
      end
    end
    puts 'PARTIALLY MATCHED UPDATED ORDERS', updated_orders_with_matching_total
    puts 'Totals(sprint/bible)', updated_orders_total.to_f, bible_total.to_f
    puts 'repeating_rows', repeating_rows

    puts 'COMPLETELY MATCHED UPDATED ORDERS', updated_orders_with_matching_total_with_tax, updated_orders_with_matching_total_with_tax.count
    puts 'Totals(sprint/bible)', updated_orders_total_with_tax.to_f, bible_total_with_tax.to_f
    puts 'QMismatch', quantity_mismatch
    puts 'MATCHED', i
    puts 'MISMATCH', j
    puts 'Corrected tax rates', corrected, corrected.count
    puts 'TAX AMT DIFF IN SHEET ', tax_mismatch, tax_mismatch.count
    puts 'HAS QR ENTRY', is_in_qr
  end

  def add_missing_skus_in_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
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
      if sales_order.present? && batch2.include?(current_row)
        puts '******************************** ITERATION *******************************', iteration
        iteration = iteration + 1

        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        if !sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
          product_in_quote = sales_order.sales_quote.rows.map {|r| r.product.sku}.include?(product_sku)
          if product_in_quote
            product_row = sales_order.sales_quote.joins(:product).where('products.sku = ?', product_sku).first
          else
            # ?
            sr_no = inquiry.inquiry_products.present? ? (inquiry.inquiry_products.last.sr_no + 1) : 1
            inquiry_product = sales_order.inquiry.inquiry_products.where(product_id: product.id, sr_no: sr_no, quantity: x.get_column('quantity')).first_or_create!


            supplier = Company.acts_as_supplier.find_by_name('Local')
            inquiry_product_supplier = InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
            inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)

            row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
          end

        else
          puts 'product exists'
        end
      end
    end
  end

  def create_missing_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('missing_orders.csv', 'seed_files_3')
    service.loop(nil) do |x|
      # next if x.get_column('Total Selling Price').to_f.negative? || x.get_column('Inquiry Number').to_i != 6076
      next if x.get_column('Inquiry Number') != 'CUM01'
      # selected = ['BM0K8Q5-200305-6076']
      puts '*********************** INQUIRY ', x.get_column('Inquiry Number')
      order_being_processed = []
      product_sku = x.get_column('Bm #').upcase
      puts 'SKU', product_sku
      product = Product.find_by_sku(product_sku)

      # current_row = product_sku + '-' + x.get_column('So #') + '-' + x.get_column('Inquiry Number')
      inquiry = Inquiry.create

      company = Company.find('jVtpmz')
      # if !inquiry.billing_address.present?
      inquiry.billing_address = company.addresses.first
      # end

      # if !inquiry.shipping_address.present?
      inquiry.shipping_address = company.addresses.first
      # end

      # if !inquiry.shipping_contact.present?
      inquiry.shipping_contact = company.contacts.first
      # end
      inquiry.inside_sales_owner = Overseer.find_by_first_name(x.get_column('Inside Sales Name').split(' ')[0])
      inquiry.created_at = Date.parse(2018, 10, 01).strftime('%y-%m-%d')
      inquiry.old_inquiry_number = 'CUM01'

      #
      #   sales_quote = inquiry.sales_quotes.last
      #   if sales_quote.blank?
      #     sales_quote = inquiry.sales_quotes.create!(overseer: inquiry.inside_sales_owner)
      #   end
      #
      inquiry_product = inquiry.inquiry_products.where(product_id: product.id).first_or_create!
      # if inquiry_products.blank?
      #   similar_products = Product.where(name: product.name).where.not(sku: product.sku)
      #   if similar_products.present?
      #     similar_products.update_all(is_active: false)
      #   end
      #   sr_no = inquiry.inquiry_products.present? ? (inquiry.inquiry_products.last.sr_no + 1) : 1
      #   inquiry_product = inquiry.inquiry_products.where(product_id: product.id, sr_no: sr_no, quantity: x.get_column('quantity')).first_or_create!
      # else
      #   inquiry_product = inquiry_products.first
      #   if quantity < sheet_quantity
      inquiry_product.update_attribute('quantity', x.get_column('quantity').to_f)
      # end
      inquiry_product.save(validate: false)
      inquiry.save(validate: false)

      #   # supplier = Company.acts_as_supplier.find_by_name('Local')
      #   # check
      #   # inquiry_product_supplier = inquiry_product.suppliers.first
      #   # || InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
      #   # inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('unit cost price').to_f)
      #   # row = nil
      #   # if inquiry.sales_orders.pluck(:order_number).include?(x.get_column('order number').to_i)
      #   #   so = SalesOrder.find_by_order_number(x.get_column('order number').to_i)
      #   #   if so.rows.map {|r| r.product.sku}.include?(x.get_column('product sku'))
      #   #     row = sales_quote.rows.joins(:product).where('products.sku = ?', x.get_column('product sku')).first
      #   #   end
      #   # end
      #   # if row.blank?
      #   # row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
      #   # # end
      #   #
      #   # tax_rate = TaxRate.where(tax_percentage: x.get_column('tax rate').to_f).first_or_create!
      #   # row.unit_selling_price = x.get_column('unit selling price (INR)').to_f
      #   # row.quantity = x.get_column('quantity')
      #   # row.margin_percentage = x.get_column('margin percentage')
      #   # row.converted_unit_selling_price = x.get_column('unit selling price (INR)').to_f
      #   # row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
      #   # row.measurement_unit = MeasurementUnit.find_by_name(x.get_column('measurement unit')) || MeasurementUnit.default
      #   # row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
      #   # row.tax_rate = tax_rate || nil
      #   # row.created_at = x.get_column('created at', to_datetime: true)
      #   #
      #   # row.save!
      #   #
      #   # puts '**************** QUOTE ROW SAVED ********************'
      #
      #   if !order_being_processed.include?(x.get_column('So #'))
      #     overseer = Overseer.find_by_first_name(x.get_column('Inside Sales Name').split(' ')[0])
      #     revised_quote = Services::Overseers::SalesQuotes::BuildFromSalesQuote.new(inquiry.sales_quotes.last, overseer).call
      #     revised_quote.save(validate: false)
      #     revised_quote.update_attributes(created_at: DateTime.parse(x.get_column('Order Date')).strftime('%Y-%m-%d %H:%M:%S'), sent_at: DateTime.parse(x.get_column('Order Date')).strftime('%Y-%m-%d %H:%M:%S'))
      #
      #     extra_rows = revised_quote.rows.joins(:product).where.not(products: {sku: ['BM0K8Q5', 'BM0K8V4', 'BM0L0A6']})
      #     extra_rows.delete_all
      #     sales_order = revised_quote.sales_orders.where(order_number: x.get_column('So #')).first_or_create!
      #     sales_order.order_number = x.get_column('So #')
      #
      #     # sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(revised_quote, overseer).call
      #     # sales_order.update_attributes(sent_at: Time.now, status: 'Approved')
      #
      #     sales_order.overseer = inquiry.inside_sales_owner
      #     sales_order.created_at = DateTime.parse(x.get_column('Order Date')).strftime('%Y-%m-%d %H:%M:%S')
      #     sales_order.mis_date = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
      #
      #     sales_order.status = 'Approved'
      #     sales_order.remote_status = 'Processing'
      #     sales_order.sent_at = revised_quote.created_at
      #     sales_order.save!
      #   else
      #     order_being_processed.push(x.get_column('So #'))
      #   end
      #
      #   sales_order = SalesOrder.find_by_order_number(x.get_column('So #').to_i)
      #   quote_row = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku).first
      #
      #   puts '************************** ORDER SAVED *******************************'
      #   sales_order.rows.where(sales_quote_row: quote_row).first_or_create!
      #   puts '****************** ORDER TOTAL ****************************', sales_order.order_number, sales_order.calculated_total_with_tax
      # end
    end
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_till_june.csv', 'seed_files_3')
    service.loop(100) do |x|
      bible_total_with_tax = x.get_column('Total Selling Price').to_f + x.get_column('Tax Amount').to_f

      if bible_total_with_tax.negative?
        # bible_order = BibleSalesOrder.where(inquiry_number: x.get_column('Inquiry Number').to_i,
        #                                     order_number: x.get_column('So #'),
        #                                     client_order_date: x.get_column('Client Order Date'),
        #                                     is_adjustment_entry: true).first_or_create! do |bible_order|
        #   bible_order.inside_sales_owner = x.get_column('Inside Sales Name')
        #   bible_order.company_name = x.get_column('Magento Company Name')
        #   bible_order.account_name = x.get_column('Company Alias')
        #   bible_order.currency = x.get_column('Price Currency')
        #   bible_order.document_rate = x.get_column('Document Rate')
        #   bible_order.metadata = []
        # end
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
          # bible_order.is_adjustment_entry = false
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

    BibleSalesOrder.all.each do |bible_order|
      bible_order.metadata.each do |line_item|
        bible_order_total = bible_order_total + line_item['total_selling_price']
        bible_order_tax = bible_order_tax + line_item['tax_amount']
        bible_order_total_with_tax = bible_order_total_with_tax + bible_order_total + bible_order_tax
        bible_order.update_attributes(order_total: bible_order_total, order_tax: bible_order_tax, order_total_with_tax: bible_order_total_with_tax)
      end
    end
    puts 'BibleSO', BibleSalesOrder.count
  end

  def check_bible_total
    @bible_order_total = 0
    @bible_order_tax = 0
    @bible_order_total_with_tax = 0
    @margin_amount = 0

    BibleSalesOrder.all.each do |bible_order|
      bible_order.metadata.each do |line_item|
        @bible_order_total = @bible_order_total + line_item['total_selling_price']
        @bible_order_tax = @bible_order_tax + line_item['tax_amount']
        @bible_order_total_with_tax = @bible_order_total_with_tax + line_item['total_selling_price_with_tax']
        @margin_amount = @margin_amount + line_item['margin_amount']
      end
    end
    puts 'BIBLE ORDER TOTAL', @bible_order_total
    puts 'Bible TAX', @bible_order_tax
    puts 'TwTax', @bible_order_total_with_tax
    puts 'Total margin', @margin_amount
  end


  def flex_dump
    column_headers = ['Order Date', 'OD', 'Order ID', 'PO Number', 'Part Number', 'Account Gp', 'Line Item Quantity', 'Line Item Net Total', 'Order Status', 'Account User Email', 'Shipping Address', 'Currency', 'Product Category', 'Part number Description']
    start_at = Date.today.last_week.beginning_of_week.beginning_of_day
    end_at = Date.today.last_week.end_of_week.end_of_day

    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      flex_offline_orders = SalesOrder.joins(:company).where(companies: {id: 1847}).where(created_at: start_at..end_at).order(name: :asc)
      flex_offline_orders.each do |order|
        if !order.inquiry.customer_order.present?
          order.rows.each do |record|
            sales_order = record.sales_order
            order_date = sales_order.inquiry.customer_order_date.strftime('%F')
            order_cd = sales_order.created_at.strftime('%F')
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

            writer << [order_date, order_cd, order_id, customer_po_number, part_number, account, line_item_quantity, line_item_net_total, sap_status, user_email, shipping_address, currency, category, part_number_description]
          end
        end
      end

      flex_online_orders = CustomerOrder.joins(:company).where(companies: {id: 1847}).where(created_at: start_at..end_at).order(name: :asc)
      flex_online_orders.each do |order|
        order.rows.each do |record|
          sales_order = record.sales_order
          order_date = sales_order.inquiry.customer_order_date.strftime('%F')
          order_cd = sales_order.created_at.strftime('%F')
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

          writer << [order_date, order_cd, order_id, customer_po_number, part_number, account, line_item_quantity, line_item_net_total, sap_status, user_email, shipping_address, currency, category, part_number_description]
        end
      end
    end

    fetch_csv('flex_order_data_export_weekly2.csv', csv_data)
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
        'Customer Name',
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
        customer_name = inquiry.company.name.to_s
        invoice_status = sales_order.remote_status

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

  def material_readiness_dump
    column_headers = ['PO Request', 'Inquiry', 'Customer Company Name', 'Material Status', 'Supplier PO', 'Supplier PO Date', 'Supplier Name', 'PO Type', 'Latest Comment', 'Sales Order Date', 'Sales Order', 'Committed Date to Customer', 'IS&P', 'Logistics Owner', 'Material Follow Up Date', 'Expected Delivery Date', 'Payment Request status', 'Percentage Paid', 'Requested Date', 'Buying Price', 'Selling Price', 'PO Margin %', 'Overall Margin %']

    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model = PurchaseOrder
      query = model.all.where(material_status: ['Material Readiness Follow-Up', 'Inward Dispatch', 'Inward Dispatch: Partial', 'Material Partially Delivered']).joins(:po_request).where.not(po_requests: {id: nil}).where(po_requests: {status: 'Supplier PO Sent'})
      query.find_each(batch_size: 500) do |purchase_order|
        po_request = purchase_order.po_request.present? ? purchase_order.po_request.id : '-'
        inquiry_number = purchase_order.inquiry.inquiry_number
        company_name = purchase_order.inquiry.company.try(:name)
        material_status = purchase_order.material_status
        supplier_po = purchase_order.po_number
        supplier_po_date = (purchase_order.po_date ? format_succinct_date(purchase_order.po_date) : '-')

        supplier_name = purchase_order.supplier.try(:name)
        po_type = purchase_order.po_request.present? ? purchase_order.po_request.supplier_po_type : '-'
        latest_comment = (purchase_order.last_comment) if purchase_order.last_comment.present?
        sales_order_date = (format_succinct_date(purchase_order.po_request.sales_order.mis_date) if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?)
        sales_order = (purchase_order.po_request.sales_order.order_number if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?)
        committed_date_to_customer = format_succinct_date(purchase_order.po_request.inquiry.customer_committed_date) if purchase_order.po_request.present?
        inside_sales_owner = purchase_order.inquiry.inside_sales_owner.to_s
        logistics_owner = (purchase_order.logistics_owner.present? ? purchase_order.logistics_owner.full_name : 'Unassigned')
        material_follow_up_date = format_succinct_date(purchase_order.followup_date)
        expected_delivery_date = format_succinct_date(purchase_order.revised_supplier_delivery_date)
        payment_request_status = (purchase_order.payment_request.present? ? purchase_order.payment_request.status : 'Payment Request: Pending')
        percentage_paid = percentage(purchase_order.payment_request.percent_amount_paid, precision: 2) if purchase_order.payment_request.present?
        requested_date = format_succinct_date(purchase_order.email_sent_to_supplier_date)
        buying_price = purchase_order.po_request.buying_price if purchase_order.po_request.present?
        selling_price = purchase_order.po_request.selling_price if purchase_order.po_request.present?
        po_margin_percentage = purchase_order.po_request.po_margin_percentage if purchase_order.po_request.present?
        calculated_total_margin_percentage = purchase_order.po_request.sales_order.calculated_total_margin_percentage if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?

        writer << [po_request, inquiry_number, company_name, material_status, supplier_po, supplier_po_date, supplier_name, po_type, latest_comment, sales_order_date, sales_order, committed_date_to_customer, inside_sales_owner, logistics_owner, material_follow_up_date, expected_delivery_date, payment_request_status, percentage_paid, requested_date, buying_price, selling_price, po_margin_percentage, calculated_total_margin_percentage]
      end
    end

    fetch_csv('mrq_export.csv', csv_data)
  end

  def mark_zero_tsp_orders_as_cancelled
    zero_tsp = []
    not_updated = []

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)

      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        if order_number == 'Not Booked'
          inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders
          if inquiry_orders.count > 1
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

      if sales_order.present? && bible_order_row_total.to_f.zero?
        sales_order.status = 'Cancelled'
        sales_order.remote_status = 'Cancelled by SAP'
        sales_order.save(validate: false)
        if sales_order.status == 'Cancelled' && sales_order.remote_status == 'Cancelled by SAP'
          zero_tsp.push(order_number)
        else
          not_updated.push(order_number)
        end
      end
    end
    # 3RSvVY
    puts 'ZERO TSP', zero_tsp, zero_tsp.count
    puts 'NOT UPDATED CORRECTLY', not_updated, not_updated.count
  end

  def fix_date_formats_in_orders
    # mis_dates
    SalesOrder.where('mis_date < ?', Date.new(2015, 01, 01)).each do |order|
      order.update_attributes(mis_date: Date.parse(Date.parse(order.mis_date.to_s).strftime('%y-%m-%d').to_s).strftime('%Y-%m-%d'))
    end

    SalesInvoice.where('mis_date < ?', Date.new(2015, 01, 01)).each do |invoice|
      invoice.update_attributes(mis_date: Date.parse(Date.parse(invoice.mis_date.to_s).strftime('%y-%m-%d').to_s).strftime('%Y-%m-%d'))
    end

    # created_at
    SalesOrder.where('created_at < ?', Date.new(2015, 01, 01)).each do |order|
      order.update_attributes(created_at: DateTime.parse(DateTime.parse(order.created_at.to_s).strftime('%y-%m-%d %H:%M:%S').to_s).strftime('%Y-%m-%d %H:%M:%S'))
    end

    SalesInvoice.where('created_at < ?', Date.new(2015, 01, 01)).each do |invoice|
      invoice.update_attributes(created_at: DateTime.parse(DateTime.parse(invoice.created_at.to_s).strftime('%y-%m-%d %H:%M:%S').to_s).strftime('%Y-%m-%d %H:%M:%S'))
    end
  end

  def check_statuses_of_credit_entries
    SalesOrder.where(is_credit_note_entry: true).each do |order|
      parent_order = SalesOrder.find(order.parent_id)
      puts '************STATUS**************', parent_order.status
      puts '************REMOTE STATUS**************', parent_order.remote_status
      # if parent_order.status != 'CO'
      #   parent_order.status = 'CO'
      #   parent_order.save(validate: false)
      # end
    end
  end

  def october_to_may_order_dump
    column_headers = [
        'Inquiry Number',
        'Order Number',
        'Order Date',
        'Mis Date',
        'Company Name',
        'Company Alias',
        'Order Net Amount',
        'Order Tax Amount',
        'Order Total Amount',
        'Sprint Status',
        'SAP Status',
        'Inside Sales',
        'Outside Sales',
        'Sales Manager',
        'Credit Note Entry',
        'Quote Type',
        'Opportunity Type'
    ]

    start_at = Date.new(2018, 10, 01).beginning_of_month.beginning_of_day
    end_at = Date.new(2019, 05, 31).end_of_month.end_of_day

    model = SalesOrder
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.where.not(sales_quote_id: nil).where(mis_date: start_at..end_at).order(mis_date: :desc).each do |sales_order|
        inquiry = sales_order.inquiry
        inquiry_number = inquiry.try(:inquiry_number) || ''
        order_number = sales_order.order_number
        order_date = sales_order.created_at.to_date.to_s
        mis_date = sales_order.mis_date.to_date.to_s
        company_alias = inquiry.try(:account).try(:name)
        company_name = inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : ''
        gt_exc = (sales_order.calculated_total == 0) ? (sales_order.calculated_total == nil ? 0 : '%.2f' % sales_order.calculated_total) : ('%.2f' % sales_order.calculated_total)
        tax_amount = ('%.2f' % sales_order.calculated_total_tax if sales_order.inquiry.present?)
        gt_inc = ('%.2f' % sales_order.calculated_total_with_tax if sales_order.inquiry.present?)
        status = sales_order.status
        remote_status = sales_order.remote_status
        inside_sales = sales_order.inside_sales_owner.try(:full_name)
        outside_sales = sales_order.outside_sales_owner.try(:full_name)
        sales_manager = inquiry.sales_manager.full_name
        credit_note_entry = sales_order.is_credit_note_entry ? 'Yes' : 'No'
        quote_type = inquiry.try(:quote_category) || ''
        opportunity_type = inquiry.try(:opportunity_type) || ''

        writer << [inquiry_number, order_number, order_date, mis_date, company_alias, company_name, gt_exc, tax_amount, gt_inc, status, remote_status, inside_sales, outside_sales, sales_manager, credit_note_entry, quote_type, opportunity_type]
      end
    end
    fetch_csv('sprint_order_data1.csv', csv_data)
  end

  def temp
    column_headers = [
        'Inside Sales Name',
        'Client Order Date',
        'Price Currency',
        'Document Rate',
        'Magento Company Name',
        'Company Alias',
        'Inquiry Number',
        'So #',
        'Order Date',
        'Bm #',
        'Order Qty',
        'Unit Selling Price',
        'Freight',
        'Tax Type',
        'Tax Rate',
        'Tax Amount',
        'Total Selling Price',
        'Total Landed Cost',
        'Unit cost price',
        'Margin',
        'Margin (In %)'
    ]
    iteration = 1

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        puts '********************************* ITERATION ************************************', iteration
        iteration = iteration + 1

        order_number = x.get_column('So #')
        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)

        next if bible_order_row_total.to_f.zero?

        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          if order_number == 'Not Booked'
            inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders

            if inquiry_orders.count > 1
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

        if bible_order_row_total.negative?
          ae_sales_order = SalesOrder.where(parent_id: sales_order.id, is_credit_note_entry: true).first
          sales_order = ae_sales_order
        end

        if !sales_order.present?
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
                     x.get_column('Margin (In %)')]
        end
      end
    end

    fetch_csv('missing_orders.csv', csv_data)
  end

  def update_mis_date
    service = Services::Shared::Spreadsheets::CsvImporter.new('update_mis_date.csv', 'seed_files_3')
    i = 1
    service.loop(nil) do |x|
      order_number = x.get_column('Order Number')
      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        sales_order = SalesOrder.find_by_old_order_number(order_number)
      else
        sales_order = SalesOrder.find_by_order_number(order_number.to_i)
      end
      sales_order.mis_date = Date.parse(x.get_column('Bible MIS Date')).strftime('%Y-%m-%d')
      sales_order.save(validate: false)
      puts 'ITERATION', i
      i = i + 1
    end
  end

  # on hold
  def update_order_status_to_cancelled
    order_numbers = ['2003288', '10290', '10228', '10216', '10260', '10008', '10278', '10038', '10210', '10072', '10283', '10280', '10253', '10247', '10106', '10197', '10248', '10080', '10291', '10240', '10160', '10100', '10243', '10204', '10137', '10225', '10128', '10131', '10062', '10089', '10101', '10147', '10156', '10148', '10221', '10149', '10150', '10203', '10173', '10199', '10146', '10198', '10172', '10120', '10121', '10122', '10123', '10154', '10104', '10155', '10125', '10159', '10077', '10126', '10135', '10130', '10143', '10127', '10174', '10136', '10129', '10113', '10176', '10001', '10029', '10242', '10002', '10003', '10004', '10005', '10006', '10007', '10009', '10010', '10011', '10012', '10013', '10014', '10015', '10016', '10017', '10018', '10019', '10020', '10021', '10022', '10023', '10024', '10025', '10026', '10027', '10028', '10030', '10031', '10032', '10033', '10034', '10035', '10036', '10037', '10039', '10040', '10041', '10042', '10043', '10044', '10045', '10046', '10047', '10048', '10049', '10050', '10051', '10052', '10053', '10054', '10055', '10056', '10057', '10058', '10059', '10060', '10061', '10063', '10064', '10065', '10066', '10067', '10068', '10069', '10070', '10071', '10073', '10074', '10075', '10076', '10078', '10079', '10081', '10082', '10083', '10084', '10085', '10086', '10087', '10088', '10090', '10091', '10092', '10093', '10094', '10095', '10096', '10097', '10098', '10099', '10102', '10103', '10105', '10107', '10108', '10109', '10110', '10111', '10112', '10114', '10115', '10116', '10117', '10118', '10119', '10124', '10132', '10133', '10134', '10138', '10139', '10140', '10141', '10142', '10144', '10145', '10151', '10152', '10153', '10157', '10158', '10161', '10162', '10163', '10164', '10165', '10166', '10167', '10168', '10169', '10170', '10171', '10175', '10177', '10178', '10179', '10180', '10181', '10182', '10183', '10184', '10185', '10186', '10187', '10188', '10189', '10190', '10191', '10192', '10193', '10194', '10195', '10196', '10200', '10201', '10202', '10205', '10206', '10207', '10208', '10209', '10211', '10212', '10213', '10214', '10215', '10217', '10218', '10219', '10220', '10222', '10223', '10224', '10226', '10227', '10229', '10230', '10231', '10232', '10233', '10234', '10235', '10236', '10237', '10238', '10239', '10241', '10244', '10245', '10246', '10249', '10250', '10251', '10252', '10254', '10255', '10256', '10257', '10258', '10259', '10261', '10262', '10263', '10264', '10265', '10266', '10267', '10268', '10269', '10270', '10271', '10272', '10273', '10274', '10275', '10276', '10277', '10279', '10281', '10282', '10284', '10285', '10286', '10287', '10288', '10289', '10292', '10293', '10294', '10295', '10296', '10297', '10298', '10299', '10300', '10301', '10302', '10303', '10304', '10305', '10306', '10307', '10308', '10309', '10310', '10311', '10312', '10313', '10314', '10315', '10316', '10317', '10318']
    order_numbers.each do |order_number|
      sales_order = SalesOrder.find_by_order_number(order_number.to_i)
      sales_order.status = 'Cancelled'
      sales_order.save(validate: false)
    end
  end

  def update_selected
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-28 Bible Fields for Migration.csv', 'seed_files_3')
    corrected = []
    tax_mismatch = []
    repeating_rows = []
    quantity_mismatch = []
    tax_rate_difference = []
    is_in_qr = []

    repeating_matching_bible_rows = 0
    repeating_matching_rows_total = 0

    updated_orders_with_matching_total_with_tax = []
    updated_orders_total_with_tax = 0
    bible_total_with_tax = 0

    order_being_processed = []

    updated_orders_with_matching_total = []
    updated_orders_total = 0
    bible_total = 0

    i = 0
    j = 0
    iteration = 1

    kit = ['BM9P9A1-10212364', 'BM00043-10300070', 'BM9R6D3-10610467']
    except_vat_cst = ['BM9E4Z8-2000956', 'BM1A4X2-2001311', 'BM9G1U8-2001775', 'BM9L6D8-10210328', 'BM9L6D9-10210328', 'BM9Q5P6-10210580', 'BM9T4N8-10210580', 'BM9X7E1-10210580', 'BM9S5M2-10210696', 'BM9V3M1-10210696', 'BM9P7B6-10210736', 'BM00008-10210780', 'BM9P8D8-10210780', 'BM9Y8U9-10210780', 'BM9Q1T8-10211030', 'BM0O7G3-10910112', 'BM9M5D3-11410018', 'BM9M5D3-11410025', 'BM9K1B2-99999036', 'BM9K1B4-99999036', 'BM9K1B4-210200096', 'BM0C8Y9-Order2', 'BM0C9M9-Order2']

    selected = ['10210780']
    # 10210559
    # 10210780

    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      product_sku = x.get_column('Bm #').to_s.upcase
      current_row = product_sku + '-' + order_number

      if selected.include?(order_number)
        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          if order_number == 'Not Booked'
            inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders

            if inquiry_orders.count > 1
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
          puts '******************************** ITERATION *******************************', iteration
          iteration = iteration + 1

          # if !order_being_processed.include?(sales_order.order_number)
          #   if sales_order.inquiry.final_sales_quote == sales_order.sales_quote
          #     overseer = Overseer.find_by_first_name(x.get_column('Inside Sales Name').split(' ')[0])
          #     binding.pry
          #     revised_quote = Services::Overseers::SalesQuotes::BuildFromSalesQuote.new(sales_order.sales_quote, overseer).call
          #     revised_quote.save(validate: false)
          #     revised_quote.update_attributes(created_at: DateTime.parse(x.get_column('Client Order Date')).strftime('%Y-%m-%d %H:%M:%S'), sent_at: DateTime.parse(x.get_column('Client Order Date')).strftime('%Y-%m-%d %H:%M:%S'))
          #     binding.pry
          #
          #     extra_rows = revised_quote.rows.joins(:product).where.not(products: {sku: ['BM9P8D8', 'BM9Y8U9', 'BM00008']})
          #     extra_rows.delete_all
          #
          #     sales_order.update_attributes(sales_quote_id: revised_quote.id)
          #     order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
          #     quote_row = revised_quote.rows.joins(:product).where('products.sku = ?', product_sku).first
          #     order_row.update_attributes(sales_quote_row_id: quote_row.id)
          #   end
          # else
          #   order_being_processed.push(sales_order.order_number)
          # end
          #
          # order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
          # quote_row = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku).first
          # order_row.update_attributes(sales_quote_row_id: quote_row.id)

          bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
          bible_order_tax_total = x.get_column('Tax Amount').to_f
          bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            quote_row = order_row.sales_quote_row

            if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))
              tax_rate_percentage = x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_d
              tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first_or_create!
            else
              tax_rate_percentage = x.get_column('Tax Rate').split('%')[0].to_d
              tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first
            end

            # main
            if x.get_column('Tax Rate').present? && x.get_column('Tax Type').present? && x.get_column('Tax Type').scan(/^\d*(?:\.\d+)?/)[0].to_f != x.get_column('Tax Rate').split('%')[0].to_f
              tax_rate_difference.push(current_row)
            end
            binding.pry
            quote_row.quantity = x.get_column('Order Qty').to_f
            quote_row.unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.converted_unit_selling_price = x.get_column('Unit Selling Price').to_f
            quote_row.margin_percentage = x.get_column('Margin (In %)').split('%')[0].to_d
            quote_row.tax_rate = tax_rate || nil
            quote_row.tax_type = x.get_column('Tax Type') if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') || x.get_column('Tax Type').include?('Service'))

            quote_row.legacy_applicable_tax_percentage = tax_rate_percentage.to_d || nil
            quote_row.inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)
            # quote_row.created_at = Date.parse(Date.new(2019,04,01)).strftime('%Y-%m-%d')
            quote_row.created_at = x.get_column('Order Date') == '#N/A' ? sales_order.created_at : Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            quote_row.save(validate: false)
            puts '****************************** QUOTE ROW SAVED ****************************************'
            quote_row.sales_quote.save(validate: false)
            puts '****************************** QUOTE SAVED ****************************************'
            binding.pry
            order_row.quantity = x.get_column('Order Qty').to_f
            sales_order.sent_at = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            sales_order.mis_date = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            order_row.created_at = x.get_column('Order Date') == '#N/A' ? sales_order.created_at : Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            order_row.save(validate: false)
            puts '****************************** ORDER ROW SAVED ****************************************'
            sales_order.save(validate: false)
            puts '****************************** ORDER SAVED ****************************************'

            new_row_total = order_row.total_selling_price.to_f.round(2)
            new_row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)
            tax_amount = ((tax_rate_percentage.to_f / 100) * new_row_total).to_f.round(2)
            binding.pry
            if (order_row.total_tax.to_f.round(2) == tax_amount) && (new_row_total == bible_order_row_total)
              if updated_orders_with_matching_total_with_tax.include?(current_row)
                repeating_rows.push(current_row)
                repeating_matching_rows_total = repeating_matching_rows_total + new_row_total_with_tax
                repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
              else
                i = i + 1
                puts 'Matched order count', i
                updated_orders_with_matching_total_with_tax.push(x.get_column('Inquiry Number') + '-' + current_row)
                updated_orders_total_with_tax = updated_orders_total_with_tax + new_row_total_with_tax
                bible_total_with_tax = bible_total_with_tax + bible_order_row_total_with_tax
                corrected.push(x.get_column('Inquiry Number') + '-' + current_row)
              end
            elsif (order_row.total_tax.to_f.round(2) != tax_amount) || (new_row_total != bible_order_row_total)
              j = j + 1
              puts 'Mismatched order count', j
              updated_orders_with_matching_total.push(current_row)
              updated_orders_total = updated_orders_total + new_row_total_with_tax
              bible_total = bible_total + bible_order_row_total_with_tax
              tax_mismatch.push(current_row)
            else
              # binding.pry
            end
          else
            # add missing skus in sprint
          end
        else
          # add missing orders in sprint
        end
      end
    end
    puts 'PARTIALLY MATCHED UPDATED ORDERS', updated_orders_with_matching_total
    puts 'Totals(sprint/bible)', updated_orders_total.to_f, bible_total.to_f
    puts 'repeating_rows', repeating_rows

    puts 'COMPLETELY MATCHED UPDATED ORDERS', updated_orders_with_matching_total_with_tax, updated_orders_with_matching_total_with_tax.count
    puts 'Totals(sprint/bible)', updated_orders_total_with_tax.to_f, bible_total_with_tax.to_f
    puts 'QMismatch', quantity_mismatch
    puts 'MATCHED', i
    puts 'MISMATCH', j
    puts 'Corrected tax rates', corrected, corrected.count
    puts 'TAX AMT DIFF IN SHEET ', tax_mismatch, tax_mismatch.count
    puts 'HAS QR ENTRY', is_in_qr
  end


  def oct_to_march_mismatch
    column_headers = ['Inside Sales Name',
                      'Posting Date',
                      'MIS Date',
                      'Price Currency',
                      'Document Rate',
                      'Magento Company Name',
                      'Inquiry Number', 'So #', 'Bm #', 'Order Qty', 'Unit Selling Price', 'Freight', 'Tax Rate', 'Tax Amount', 'Total Selling Price', 'Unit cost price', 'Margin', 'Margin (In %)', 'Kit', 'AE', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']
    matching_orders = []
    repeating_skus = []
    missing_skus = []
    missing_orders = []
    ae_entries = []
    iteration = 1
    multiple_not_booked_orders = []
    matching_rows_total = 0
    matching_bible_rows = 0

    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_october_to_march.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        puts '********************************* ITERATION ************************************', iteration
        iteration = iteration + 1
        is_adjustment_entry = 'No'
        order_number = x.get_column('Document Number')
        product_sku = x.get_column('Item No.').to_s.upcase
        current_row = product_sku + '-' + order_number

        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        next if bible_order_row_total.to_f.zero?

        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          if order_number == 'Not Booked'
            inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Project Code')).sales_orders

            if inquiry_orders.count > 1
              multiple_not_booked_orders.push(x.get_column('Item No.') + '-' + x.get_column('Posting Date') + '-' + x.get_column('So #'))
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

        if bible_order_row_total.negative?
          ae_sales_order = SalesOrder.where(parent_id: sales_order.id, is_credit_note_entry: true).first
          sales_order = ae_sales_order
        end

        if sales_order.present?
          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price.to_f.round(2)
            row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)

            # adjustment entries
            if (row_total == -(bible_order_row_total)) || (row_total_with_tax == -(bible_order_row_total_with_tax)) || bible_order_row_total_with_tax.negative? || bible_order_row_total.negative?
              is_adjustment_entry = 'Yes'
            end

            tax_rate_percentage = x.get_column('Tax Rate').split('%')[0].to_d
            tax_amount = ((tax_rate_percentage.to_f / 100) * row_total).to_f.round(2)

            if ((row_total != bible_order_row_total) || (order_row.total_tax.to_f.round(2) != tax_amount)) &&
                (row_total - bible_order_row_total).abs > 1

              # KIT check
              if sales_order.calculated_total.to_f.round(2) == bible_order_row_total &&
                  sales_order.calculated_total_with_tax.to_f.round(2) == bible_order_row_total_with_tax
                writer << [x.get_column('Inside Sales Owner'),
                           x.get_column('Posting Date'),
                           x.get_column('MIS Date'),
                           x.get_column('Price Currency'),
                           x.get_column('Document Rate'),
                           x.get_column('Magento Company Name').present? ? x.get_column('Magento Company Name').gsub(';', ' ') : '-',
                           x.get_column('Project Code'),
                           x.get_column('Document Number'),
                           x.get_column('Item No.'),
                           x.get_column('Quantity'),
                           x.get_column('Unit Selling Price'),
                           x.get_column('Freight'),
                           x.get_column('Tax Rate'),
                           x.get_column('Tax Amount'),
                           x.get_column('Total Selling Price'),
                           x.get_column('Unit cost price'),
                           x.get_column('Margin'),
                           x.get_column('Margin (In %)'), 'Yes', is_adjustment_entry,
                           row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax]
              else
                writer << [x.get_column('Inside Sales Owner'),
                           x.get_column('Posting Date'),
                           x.get_column('MIS Date'),
                           x.get_column('Price Currency'),
                           x.get_column('Document Rate'),
                           x.get_column('Magento Company Name').present? ? x.get_column('Magento Company Name').gsub(';', ' ') : '-',
                           x.get_column('Project Code'),
                           x.get_column('Document Number'),
                           x.get_column('Item No.'),
                           x.get_column('Quantity'),
                           x.get_column('Unit Selling Price'),
                           x.get_column('Freight'),
                           x.get_column('Tax Rate'),
                           x.get_column('Tax Amount'),
                           x.get_column('Total Selling Price'),
                           x.get_column('Unit cost price'),
                           x.get_column('Margin'),
                           x.get_column('Margin (In %)'), 'No', is_adjustment_entry,
                           row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax]
              end
            else
              if matching_orders.include?(current_row)
                repeating_skus.push(current_row)
              else
                matching_bible_rows = matching_bible_rows + bible_order_row_total_with_tax
                matching_rows_total = matching_rows_total + row_total_with_tax
                matching_orders.push(current_row)
              end
            end
          else
            missing_skus.push(current_row)
          end
        else
          if !bible_order_row_total.negative?
            missing_orders.push(current_row)
          else
            ae_entries.push(current_row)
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
      puts 'AE ENTRIES', ae_entries, ae_entries.count
    end

    fetch_csv('mismatch_after_usd_1.csv', csv_data)
  end

  def update_selected_in_oct_to_march
    service = Services::Shared::Spreadsheets::CsvImporter.new('range_two_mismatch1.csv', 'seed_files_3')
    corrected = []
    tax_mismatch = []
    repeating_rows = []
    order_being_processed = []

    repeating_matching_bible_rows = 0
    repeating_matching_rows_total = 0

    updated_orders_with_matching_total_with_tax = []
    updated_orders_total_with_tax = 0
    bible_total_with_tax = 0

    updated_orders_with_matching_total = []
    updated_orders_total = 0
    bible_total = 0
    # selected = ['33341-BM9C6A0-10212550', '32963-BM9Y6N1-10212424', '32115-BM9P2I4-10212157', '27035-BM9P9Y2-10211658']
    # selected = ['32291-BM9T7U6-10212558', '32291-BM9Y9T0-10212558'] # USD
    # selected = ['BM9P0U7-10212459', 'BM9P0U7-10212466']
    # selected = ['BM9R4B8-10610837', 'BM0C8G8-10211991', 'BM0O7C5-10211991']
    selected = ['BM9U6V6-10211502', 'BM00008-10211502'] # 26252

    updates_correctly = ['31298-BM9Q0B2-10212546', '33341-BM9C6A0-10212550', '29459-BM9D4P4-10610738', '29459-BM9D4P3-10610738', '32963-BM9Y6N1-10212424', '29130-BM9I7E1-10610575', '29130-BM9Y9D0-10610575', '27427-BM9Z9T9-10211487', '30944-BM9G3O2-10610744', '28372-BM9A5Y0-10610498', '29130-BM9Q9L7-10610620', '29130-BM9F6D4-10610620', '29130-BM9V7Z4-10610627', '29130-BM9V5M3-10610627', '29130-BM9S1K4-10610627', '29130-BM9V7Z4-10610676', '29459-BM9G5Y3-10610738', '29459-BM9N9G5-10610738', '29459-BM1A4W7-10610738', '29459-BM0N1S2-10610738', '29459-BM0K9A5-10610738', '29459-BM9E7D8-10610738', '30229-BM9U9B5-10211632', '30229-BM9W8U3-10211632', '30229-BM9P8H5-10211632', '30229-BM9Z6T2-10211632', '30229-BM9R7E3-10211632', '30229-BM9R7U2-10211632', '30229-BM9R4Y5-10211632', '30229-BM9R2H4-10211632', '30229-BM9Q2C6-10211632', '30229-BM9V6H6-10211632', '29459-BM9N1N3-10610738', '31727-BM9U9B5-10212120', '31727-BM9W8U3-10212120', '31727-BM9P8H5-10212120', '31727-BM9Z6T2-10212120', '31727-BM9R7E3-10212120', '31727-BM9R7U2-10212120', '31727-BM9R4Y5-10212120', '31727-BM9R2H4-10212120', '31727-BM9Q2C6-10212120', '31727-BM9V6H6-10212120', '29459-BM9U2Z2-10610738', '29459-BM9M4J9-10610738', '29114-BM9D2A6-10211325', '30795-BM9F4G0-10211805', '31977-BM9J8I6-10610838', '33100-BM9Q3B2-10610949', '33118-BM9Q7X0-10212502', '31281-BM99992-10211991', '30239-BM4H8M5-10610693', '26252-BM9P7B6-10211307', '32909-BM9P0U7-10212459', '32909-BM9P0U7-10212466', '29095-BM9Q1T8-10211322', '30239-BM4H8M5-10610668', '29568-BM9U6V6-10211502', '25225-BM9P2X7-10610556', '31036-BM9Y7G7-10212272', '27986-BM9R6D3-10610467', '28044-BM9Q3J6-10211131', '28043-BM9U6V6-10211118', '28146-BM9R1P5-10211132', '26644-BM9M5D3-11410025', '31500-BM9B7V0-10212221', '31500-BM9O7Q3-10212221', '32115-BM9P2I4-10212157']
    i = 0
    j = 0
    iteration = 1

    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      product_sku = x.get_column('Bm #').to_s.upcase
      current_row = product_sku + '-' + order_number
      # next if product_sku == 'BM00008'
      # x.get_column('Inquiry Number') + '-' + current_row
      # next if !selected.include?(current_row) || x.get_column('Price Currency') != 'USD'
      next if !selected.include?(current_row)

      # next if x.get_column('Inquiry Number').to_i == 32291 || x.get_column('Price Currency') != 'USD'
      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        if order_number == 'Not Booked'
          inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders

          if inquiry_orders.count > 1
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
        puts '******************************** ITERATION *******************************', iteration
        iteration = iteration + 1

        # if !order_being_processed.include?(sales_order.order_number)
        #   if sales_order.inquiry.final_sales_quote == sales_order.sales_quote
        #     overseer = Overseer.find_by_email('vijay.manjrekar@bulkmro.com')
        #     binding.pry
        #     revised_quote = Services::Overseers::SalesQuotes::BuildFromSalesQuote.new(sales_order.sales_quote, overseer).call
        #     revised_quote.save(validate: false)
        #     revised_quote.update_attributes(created_at: DateTime.parse(x.get_column('Posting Date')).strftime('%Y-%m-%d %H:%M:%S'), sent_at: DateTime.parse(x.get_column('Posting Date')).strftime('%Y-%m-%d %H:%M:%S'))
        #     binding.pry
        #
        #     extra_rows = revised_quote.rows.joins(:product).where.not(products: {sku: ['BM9P0U7']})
        #     extra_rows.delete_all
        #
        #     sales_order.update_attributes(sales_quote_id: revised_quote.id)
        #     order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
        #     quote_row = revised_quote.rows.joins(:product).where('products.sku = ?', product_sku).first
        #     order_row.update_attributes(sales_quote_row_id: quote_row.id)
        #   end
        # else
        #   order_being_processed.push(sales_order.order_number)
        # end
        #
        # order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
        # quote_row = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku).first
        # order_row.update_attributes(sales_quote_row_id: quote_row.id)

        bible_order_row_total = x.get_column('Total Selling Price').to_f.round(2)
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = (bible_order_row_total + bible_order_tax_total).to_f.round(2)

        if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
          order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
          quote_row = order_row.sales_quote_row

          tax_rate_percentage = x.get_column('Tax Rate').split('%')[0].to_d
          tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first
          quote_row.quantity = x.get_column('Order Qty').to_f
          quote_row.unit_selling_price = x.get_column('Unit Selling Price').to_f
          # if x.get_column('Price Currency') == 'USD'
          #   quote_row.inquiry.inquiry_currency.conversion_rate = x.get_column('Document Rate').to_d
          #   quote_row.inquiry.inquiry_currency.save(validate: false)
          #   quote_row.converted_unit_selling_price = (x.get_column('Unit Selling Price').to_f/x.get_column('Document Rate').to_f)
          #
          #   quote_row.freight_cost_subtotal = 0
          #   quote_row.unit_freight_cost = 0
          # else
          quote_row.converted_unit_selling_price = x.get_column('Unit Selling Price').to_f
          # end
          quote_row.inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Unit cost price').to_f)
          quote_row.margin_percentage = x.get_column('Margin (In %)').split('%')[0].to_d
          quote_row.tax_rate = tax_rate || nil
          quote_row.legacy_applicable_tax_percentage = tax_rate_percentage.to_d || nil
          quote_row.created_at = Date.parse(x.get_column('Posting Date')).strftime('%Y-%m-%d')
          quote_row.save(validate: false)
          puts '****************************** QUOTE ROW SAVED ****************************************'
          quote_row.sales_quote.save(validate: false)
          puts '****************************** QUOTE SAVED ****************************************'

          order_row.quantity = x.get_column('Order Qty').to_f
          sales_order.mis_date = Date.parse(x.get_column('MIS Date')).strftime('%Y-%m-%d')
          order_row.created_at = Date.parse(x.get_column('Posting Date')).strftime('%Y-%m-%d')
          order_row.save(validate: false)
          puts '****************************** ORDER ROW SAVED ****************************************'
          sales_order.save(validate: false)
          puts '****************************** ORDER SAVED ****************************************'
          new_row_total = order_row.total_selling_price.to_f.round(2)
          new_row_total_with_tax = order_row.total_selling_price_with_tax.to_f.round(2)
          tax_amount = ((tax_rate_percentage.to_f / 100) * new_row_total).to_f.round(2)

          binding.pry
          if (order_row.total_tax.to_f.round(2) == tax_amount) && (new_row_total == bible_order_row_total)
            if updated_orders_with_matching_total_with_tax.include?(current_row)
              repeating_rows.push(current_row)
              repeating_matching_rows_total = repeating_matching_rows_total + new_row_total_with_tax
              repeating_matching_bible_rows = repeating_matching_bible_rows + bible_order_row_total_with_tax
            else
              i = i + 1
              puts 'Matched order count', i
              updated_orders_with_matching_total_with_tax.push(x.get_column('Inquiry Number') + '-' + current_row)
              updated_orders_total_with_tax = updated_orders_total_with_tax + new_row_total_with_tax
              bible_total_with_tax = bible_total_with_tax + bible_order_row_total_with_tax
              corrected.push(x.get_column('Inquiry Number') + '-' + current_row)
            end
          elsif (order_row.total_tax.to_f.round(2) != tax_amount) || (new_row_total != bible_order_row_total)
            j = j + 1
            puts 'Mismatched order count', j
            updated_orders_with_matching_total.push(current_row)
            updated_orders_total = updated_orders_total + new_row_total_with_tax
            bible_total = bible_total + bible_order_row_total_with_tax
            tax_mismatch.push(current_row)
          else
            # binding.pry
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
    puts 'MATCHED', i
    puts 'MISMATCH', j
    puts 'Corrected tax rates', corrected, corrected.count
  end


  def update_mis_dates_for_may
    service = Services::Shared::Spreadsheets::CsvImporter.new('may_bible.csv', 'seed_files_3')
    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        if order_number == 'Not Booked'
          inquiry_orders = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number')).sales_orders
          if inquiry_orders.count > 1
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
        sales_order.mis_date = Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
        sales_order.save(validate: false)
      end
    end
  end


  def all_invoice_dump
    columns = [
        'Inquiry Number',
        'Invoice Number',
        'Invoice MIS Date',
        'Order Number',
        'Order MIS Date',
        'Order Status',
        'Customer Name',
        'Invoice Net Amount',
        'Invoice Status'
    ]

    model = SalesInvoice
    csv_data = CSV.generate(write_headers: true, headers: columns) do |writer|
      model.not_cancelled.includes(:rows).where.not(sales_order_id: nil).where.not(metadata: nil).order(invoice_number: :asc).find_each(batch_size: 2000) do |sales_invoice|
        inquiry = sales_invoice.inquiry
        sales_order = sales_invoice.sales_order
        writer << [
            inquiry.try(:inquiry_number) || '',
            sales_invoice.old_invoice_number.present? ? sales_invoice.old_invoice_number : sales_invoice.invoice_number,
            sales_invoice.mis_date.present? ? sales_invoice.mis_date : '-',
            sales_order.old_order_number.present? ? sales_order.old_order_number : sales_order.order_number,
            sales_order.mis_date.present? ? sales_order.mis_date.to_date.to_s : '-',
            sales_order.remote_status,
            inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : '',
            (sales_invoice.calculated_total == 0 || sales_invoice.calculated_total == nil) ? 0 : '%.2f' % (sales_invoice.calculated_total),
            # ('%.2f' % sales_invoice.metadata['subtotal'] if sales_invoice.metadata['subtotal']),
            sales_invoice.status
        ]
      end
    end

    fetch_csv('sprint_si_dump.csv', csv_data)
  end
end
