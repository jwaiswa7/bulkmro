class Services::Overseers::Bible::CreateInvoice < Services::Overseers::Bible::BaseService
  attr_accessor :upload_sheet

  def initialize(upload = nil)
    @upload_sheet = upload
  end

  def call
    i = 0
    error = []
    invoices_in_sheet = []
    fetch_file_to_be_processed(upload_sheet)
    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_file_sheet.csv', 'bible_imports')
    upload_sheet.update(status: 'Processing')
    sheet_header = service.get_header
    defined_header = fixed_header('sales_invoices')
    begin
      if sheet_header.sort == defined_header.sort
        service.loop(nil) do |x|
          invoice_number = x.get_column('Invoice Number')
          # BibleInvoice.where(invoice_number: get_sales_invoice(invoice_number).invoice_number).last
          bible_invoice = BibleInvoice.where(invoice_number: invoice_number, mis_date: Date.parse(x.get_column('Invoice Date')).strftime('%Y-%m-%d'), invoice_type: x.get_column('Invoice/Credit Note')).last
          if bible_invoice.present?
            bible_invoice.metadata = []
            bible_invoice.save
            invoices_in_sheet.push(bible_invoice.id)
          end
        end
        service.loop(nil) do |x|
          begin
            invoice_number = x.get_column('Invoice Number')
            inquiry_number = x.get_column('Inquiry #')
            bible_invoice_row_total = x.get_column('Invoice Amount in INR').to_f
            puts '************************************ ITERATION *******************************', i
            i = i + 1

            if invoice_number.include?('.') || invoice_number.include?('/') || invoice_number.include?('-') || invoice_number.match?(/[a-zA-Z]/)
              sales_invoice = SalesInvoice.find_by_old_invoice_number(invoice_number)
            else
              sales_invoice = SalesInvoice.find_by_invoice_number(invoice_number.to_i)
            end

            inquiry = get_inquiry(inquiry_number)
            begin
              bible_invoice = BibleInvoice.where(inquiry_number: x.get_column('Inquiry #').to_i,
                                                 invoice_number: invoice_number,
                                                 mis_date: Date.parse(x.get_column('Invoice Date')).strftime('%Y-%m-%d')).first_or_create! do |bsi|
                # bible_invoice.inquiry = inquiry
                bsi.inside_sales_owner = inquiry.present? ? inquiry.inside_sales_owner : nil
                bsi.outside_sales_owner = inquiry.present? ? inquiry.outside_sales_owner : nil
                bsi.invoice_type = x.get_column('Invoice/Credit Note')
                bsi.branch_type = x.get_column('Branch')
                bsi.sales_invoice = sales_invoice.present? ? sales_invoice : nil
                bsi.company_name = x.get_column('Company Name')
                bsi.company = inquiry.present? ? inquiry.company : Company.find_by_name(x.get_column('Company Name'))
                bsi.account = inquiry.present? ? inquiry.company.account : Company.find_by_name(x.get_column('Company Name')).account
                bsi.currency = x.get_column('Invoice Currency')
                bsi.document_rate = x.get_column('Exchange Rate')
                bsi.is_credit_note_entry = bible_invoice_row_total.negative? ? true : false
                bsi.metadata = []
              end
            rescue Exception => e
              error.push(error: e.message, invoice: invoice_number)
            end

            if bible_invoice.present?
              invoice_metadata = bible_invoice.metadata
              sku_data = {
                  'sku': x.get_column('New SKU'),
                  'description': x.get_column('Description'),
                  'quantity': x.get_column('Qty'),
                  'unit_selling_price': x.get_column('Rate').to_f,
                  'total_selling_price': x.get_column('Invoice Amount in INR').to_f,
                  'total_selling_price_with_doc_currency': x.get_column('Invoice Amount in Local Curr.'),
                  'purchase_cost': x.get_column('Purchase Cost').to_f,
                  'total_landed_cost': x.get_column('Cost Of Good Sold (Viz. Sales Qty)').to_f,
                  'supplier_name': x.get_column('Supplier Name').to_s,
                  'po_quantity': x.get_column('Quantity'),
                  'ap_ref_number': x.get_column('AP Ref. No.'),
                  # 'tax_type': x.get_column('Tax Type'),
                  # 'tax_rate': x.get_column('Tax Rate'),
                  # 'tax_amount': x.get_column('Tax Amount').to_f,
                  # 'total_selling_price_with_tax': x.get_column('Total Selling Price').to_f + x.get_column('Tax Amount').to_f,
                  'margin_percentage': x.get_column('Gross Margin %').present? ? x.get_column('Gross Margin %') : '0%',
                  'margin_amount': x.get_column('Gross Margin Amount').present? ? x.get_column('Gross Margin Amount').to_f : 0,
                  'invoice_date': Date.parse(x.get_column('Invoice Date')).strftime('%Y-%m-%d')
              }
              invoice_metadata.push(sku_data)
              bible_invoice.assign_attributes(metadata: invoice_metadata)
              bible_invoice.save
            end
            upload_sheet.bible_upload_logs.create(sr_no: i, bible_row_data: x.get_row.to_json, status: 10, error: '-')
          rescue StandardError => err
            upload_sheet.bible_upload_logs.create(sr_no: i, bible_row_data: x.get_row.to_json, status: 20, error: err.message)
          end
        end

        calculate_totals(invoices_in_sheet)
        upload_sheet.update(status: 'Completed')
        puts 'BibleSI', BibleInvoice.count
      else
        upload_sheet.update(status: 'Failed')
      end
    rescue StandardError => err
      upload_sheet.bible_upload_logs.create(status: 'Failed', error: err.message)
      upload_sheet.update(status: 'Completed with Errors')
    end
    # puts 'ERROR', error
    File.delete(@path_to_tempfile) if File.exist?(@path_to_tempfile)
  end

  def get_inquiry(inquiry_number)
    if inquiry_number.include?('.') || inquiry_number.include?('/') || inquiry_number.include?('-') || inquiry_number.match?(/[a-zA-Z]/)
      inquiry = Inquiry.find_by_old_inquiry_number(inquiry_number)
    else
      inquiry = Inquiry.find_by_inquiry_number(inquiry_number.to_i)
    end

    inquiry
  end

  def get_sales_invoice(invoice_number)
    if invoice_number.include?('.') || invoice_number.include?('/') || invoice_number.include?('-') || invoice_number.match?(/[a-zA-Z]/)
      sales_invoice = SalesInvoice.find_by_old_invoice_number(invoice_number)
    else
      sales_invoice = SalesInvoice.find_by_invoice_number(invoice_number.to_i)
    end

    sales_invoice
  end

  def calculate_totals(invoices_in_sheet)
    invoices_in_sheet.uniq.each do |invoice_id|
      @bible_invoice_total = 0
      @margin_sum = 0
      @invoice_items = 0
      @invoice_margin = 0
      @overall_margin_percentage = 0

      bible_invoice = BibleInvoice.where(id: invoice_id)
      bible_invoice.metadata.each do |line_item|
        @bible_invoice_total = @bible_invoice_total + line_item['total_selling_price'].to_f
        @margin_sum = @margin_sum + line_item['margin_percentage'].split('%')[0].to_f
        @invoice_items = @invoice_items + line_item['quantity'].to_f
        @invoice_margin = @invoice_margin + line_item['margin_amount'].to_f
      end

      @overall_margin_percentage = (@margin_sum / @invoice_items).to_f
      bible_invoice.update_attributes(invoice_total: @bible_invoice_total, total_margin: @invoice_margin, overall_margin_percentage: @overall_margin_percentage)
    end
  end
end
