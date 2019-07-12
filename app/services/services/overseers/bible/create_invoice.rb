class Services::Overseers::Bible::CreateInvoice < Services::Shared::BaseService
  def initialize
  end

  def call
    error = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_invoices_17_to19.csv', 'seed_files_3')
    service.loop(nil) do |x|
      invoice_number = x.get_column('Invoice Number')
      bible_invoice_row_total = x.get_column('Invoice Amount in INR').to_f

      if invoice_number.include?('.') || invoice_number.include?('/') || invoice_number.include?('-') || invoice_number.match?(/[a-zA-Z]/)
        sales_invoice = SalesInvoice.find_by_old_invoice_number(invoice_number)
      else
        sales_invoice = SalesInvoice.find_by_invoice_number(invoice_number.to_i)
      end

      inquiry = Inquiry.find_by_inquiry_number(x.get_column('Inquiry #').to_i) || Inquiry.find_by_old_inquiry_number(x.get_column('Inquiry #'))
      begin
        bible_invoice = BibleInvoice.where(inquiry_number: x.get_column('Inquiry Number').to_i,
                                            invoice_number: invoice_number,
                                            mis_date: Date.parse(x.get_column('Invoice Date')).strftime('%Y-%m-%d')).first_or_create! do |bible_invoice|
          bible_invoice.inside_sales_owner = inquiry.inside_sales_owner
          bible_invoice.outside_sales_owner = inquiry.outside_sales_owner
          bible_invoice.invoice_type = x.get_column('Invoice/Credit Note')
          bible_invoice.branch_type = x.get_column('Branch')
          bible_invoice.sales_invoice = sales_invoice.present? ? sales_invoice : nil
          bible_invoice.company = inquiry.company # || x.get_column('Company Name ')
          bible_invoice.account = inquiry.company.account
          bible_invoice.currency = x.get_column('Invoice Currency')
          bible_invoice.document_rate = x.get_column('Exchange Rate')
          bible_invoice.is_credit_note_entry = bible_invoice_row_total.negative? ? true : false
          bible_invoice.metadata = []
        end
      rescue Exception => e
        error.push({error: e.message, invoice: invoice_number})
      end

      if bible_invoice.present?
        skus_in_invoice = bible_invoice.metadata.map {|h| h['sku']}
        puts 'SKU STATUS', skus_in_invoice.include?(x.get_column('Bm #'))

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
            'margin_percentage': x.get_column('Gross Margin %'),
            'margin_amount': x.get_column('Gross Margin Amount').to_f,
            'invoice_date': Date.parse(x.get_column('Invoice Date')).strftime('%Y-%m-%d')
        }
        invoice_metadata.push(sku_data)
        bible_invoice.assign_attributes(metadata: invoice_metadata)
        bible_invoice.save
      end
    end

    calculate_totals
    puts 'BibleSI', BibleInvoice.count
    puts 'ERROR', error
  end

  def calculate_totals
    BibleInvoice.all.each do |bible_invoice|
      @bible_invoice_total = 0
      @bible_invoice_tax = 0
      @bible_invoice_total_with_tax = 0
      @invoice_margin = 0

      bible_invoice.metadata.each do |line_item|
        @bible_invoice_total = @bible_invoice_total + line_item['total_selling_price']
        # @bible_invoice_tax = @bible_invoice_tax + line_item['tax_amount']
        # @bible_invoice_total_with_tax = @bible_invoice_total_with_tax + line_item['total_selling_price_with_tax']
        @invoice_margin = @invoice_margin + line_item['total_margin']
      end
      bible_invoice.update_attributes(invoice_total: @bible_invoice_total, total_margin: @invoice_margin)
    end
  end
end