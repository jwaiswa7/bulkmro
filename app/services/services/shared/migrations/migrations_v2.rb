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
    service.loop(limit) do |x|
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

  def missing_sap_orders
    column_headers = ['inquiry_number', 'order_number']
    i = 0
    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_so.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |csv|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('#')) || SalesOrder.find_by_old_order_number(x.get_column('#'))
        if sales_order.blank?
          csv << [x.get_column('Project'), x.get_column('#')]
        end
        i = i + 1
        puts "line #{i}, SO #{x.get_column('#')}"
      end
    end

    fetch_csv('sap_missing_orders.csv', csv_data)
  end

  def sap_sales_order_totals_mismatch
    column_headers = ['order_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_so.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('#')) || SalesOrder.find_by_old_order_number(x.get_column('#'))
        sap_total_without_tax = 0
        sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f

        if sales_order.present?
          # actual_total = (sales_order.calculated_total * sales_order.inquiry_currency.conversion_rate).to_f
          # actual_total_with_tax = (sales_order.calculated_total_with_tax * sales_order.inquiry_currency.conversion_rate).to_f

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

  def companies_export
    overseer = Overseer.find(197)
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


    filename = 'companies_export.csv'
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

end
