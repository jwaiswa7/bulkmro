class Services::Overseers::Bible::CreateOrder < Services::Shared::BaseService
  def initialize
  end

  def call
    error = []
    i = 0
    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_till_june1.csv', 'seed_files_3')
    service.loop(nil) do |x|
      puts '******************************** ITERATION ***********************************', i
      i = i + 1
      # if Date.parse(x.get_column('Order Date')).strftime('%Y-%m-%d') < Date.new(2019,04,30).end_of_day
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
          error.push({error:e.message, order: order_number})
        end

        if bible_order.present?
        # skus_in_order = bible_order.metadata.map {|h| h['sku']}
        # puts 'SKU STATUS', skus_in_order.include?(x.get_column('Bm #'))

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
      # end
    end

    calculate_totals
    puts 'BibleSO', BibleSalesOrder.count
    puts 'ERROR', error
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
      @overall_margin_percentage = (@margin_sum/@order_line_items).to_f
      bible_order.update_attributes(order_total: @bible_order_total, order_tax: @bible_order_tax, order_total_with_tax: @bible_order_total_with_tax, total_margin: @order_margin, overall_margin_percentage: @overall_margin_percentage)
    end
  end
end