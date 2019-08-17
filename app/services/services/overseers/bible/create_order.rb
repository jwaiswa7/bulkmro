class Services::Overseers::Bible::CreateOrder < Services::Shared::BaseService
  def initialize
  end

  def call
    @bible_upload_queue = BibleUpload.where(status: 'Pending')
    @bible_upload_queue.each do |upload_sheet|
      error = []
      i = 0

      fetch_file_to_be_processed(upload_sheet)
      service = Services::Shared::Spreadsheets::CsvImporter.new('bible_file_sheet.rb', 'bible_imports')
      upload_sheet.update(status: 'Processing')
      service.loop(nil) do |x|
        begin
          puts '******************************** ITERATION ***********************************', i
          i = i + 1
          order_number = x.get_column('So #')
          bible_order_row_total = x.get_column('Total Selling Price').to_f
          bible_total_with_tax = x.get_column('Total Selling Price').to_f + x.get_column('Tax Amount').to_f

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

          inquiry = Inquiry.find_by_inquiry_number(x.get_column('Inquiry #').to_i) || Inquiry.find_by_old_inquiry_number(x.get_column('Inquiry #'))
          isp_full_name = x.get_column('Inside Sales Name').to_s.strip.split
          isp_first_name = isp_full_name[0]
          isp_last_name = isp_full_name[1] if isp_full_name.length > 1

          begin
            bible_order = BibleSalesOrder.where(inquiry_number: x.get_column('Inquiry Number').to_i,
                                                order_number: x.get_column('So #'),
                                                mis_date: Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')).first_or_create! do |bo|
              # bible_order.inquiry = inquiry
              bo.inside_sales_owner = Overseer.where(first_name: isp_first_name).last
              bo.outside_sales_owner = inquiry.outside_sales_owner
              bo.sales_order = sales_order.present? ? sales_order : nil
              bo.company_name = x.get_column('Magento Company Name')
              bo.company = inquiry.company
              bo.account = inquiry.company.account # || x.get_column('Company Alias')
              bo.client_order_date = Date.parse(x.get_column('Client Order Date')).strftime('%Y-%m-%d') if x.get_column('Inquiry Number') != '31647'
              bo.currency = x.get_column('Price Currency')
              bo.document_rate = x.get_column('Document Rate')
              bo.metadata = []
            end
          rescue Exception => e
            error.push(error: e.message, order: order_number)
          end

          if bible_order.present?
            order_metadata = bible_order.metadata
            sku_data = {
                'sku': x.get_column('Bm #'),
                'description': x.get_column('Description'),
                'quantity': x.get_column('Order Qty'),
                'freight': x.get_column('Freight'),
                'total_landed_cost': x.get_column('Total Landed Cost(Total buying price)').to_f,
                'unit_cost_price': x.get_column('unit cost price').to_f,
                'unit_selling_price': x.get_column('Unit selling Price').to_f,
                'total_selling_price': x.get_column('Total Selling Price').to_f,
                'tax_type': x.get_column('Tax Type'),
                'tax_rate': x.get_column('Tax Rate'),
                'tax_amount': x.get_column('Tax Amount').to_f,
                'total_selling_price_with_tax': x.get_column('Total Selling Price').to_f + x.get_column('Tax Amount').to_f,
                'margin_percentage': x.get_column('Margin (In %)'),
                'margin_amount': x.get_column('Margin').to_f,
                'order_date': Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d')
            }
            order_metadata.push(sku_data)
            bible_order.assign_attributes(metadata: order_metadata)
            bible_order.save
          end
          upload_sheet.bible_upload_logs.create(sr_no: i, bible_row_data: x.get_row.to_json, status: true, error: '-')
        rescue StandardError => err
          upload_sheet.bible_upload_logs.create(sr_no: i, bible_row_data: x.get_row.to_json, status: false, error: err.message)
        end
      end
      calculate_totals
      upload_sheet.update(status: 'Complete')
      puts 'BibleSO', BibleSalesOrder.count
      puts 'ERROR', error
      File.delete(path_to_tempfile) if File.exist?(path_to_tempfile)
    end
  end

  def calculate_totals
    BibleSalesOrder.all.each do |bible_order|
      @bible_order_total = 0
      @bible_order_tax = 0
      @bible_order_total_with_tax = 0
      @order_margin = 0
      @margin_sum = 0
      @order_line_items = 0
      @overall_margin_percentage = 0

      bible_order.metadata.each do |line_item|
        @bible_order_total = @bible_order_total + line_item['total_selling_price'].to_f
        @bible_order_tax = @bible_order_tax + line_item['tax_amount'].to_f
        @bible_order_total_with_tax = @bible_order_total_with_tax + line_item['total_selling_price_with_tax'].to_f
        @order_margin = @order_margin + line_item['margin_amount'].to_f
        @margin_sum = @margin_sum + line_item['margin_percentage'].split('%')[0].to_f
        @order_line_items = @order_line_items + line_item['quantity'].to_f
      end
      @overall_margin_percentage = (@margin_sum / @order_line_items).to_f
      bible_order.update_attributes(order_total: @bible_order_total, order_tax: @bible_order_tax, order_total_with_tax: @bible_order_total_with_tax, total_margin: @order_margin, overall_margin_percentage: @overall_margin_percentage)
    end
  end

  def get_bible_file_upload_log
    BibleUpload.all
  end

  def fetch_file_to_be_processed(upload_sheet)
    temp_path = Tempfile.open { |tempfile| tempfile << upload_sheet.bible_attachment.download }.path
    destination_path = Rails.root.join('db', 'bible_imports')
    Dir.mkdir(destination_path) unless Dir.exist?(destination_path)
    path_to_tempfile = [destination_path, '/', 'bible_file_sheet.rb'].join
    FileUtils.mv temp_path, path_to_tempfile
  end

  def export_csv_format_for_bible
    file_name = "#{Rails.root}/tmp/bible_sales_order.csv"
    headers = ['Inside Sales Name', 'Client Order #', 'Client Order Date', 'Price Currency', 'Document Rate', 'Magento Company Name', 'Company Alias', 'Inquiry Number', 'So #', 'Order Date', 'Bm #', 'Description', 'Order Qty', 'Unit Selling Price', 'Freight', 'Tax Type', 'Tax Rate', 'Tax Amount', 'Total Selling Price', 'Total Landed Cost', 'Unit cost price', 'Margin', 'Margin (In %)', 'So Month Code']
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
    end
    temp_file = File.open(file_name, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end
end
