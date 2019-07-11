class Services::Overseers::BibleSalesOrders::Create < Services::Shared::BaseService
  def initialize
  end

  def call
  service = Services::Shared::Spreadsheets::CsvImporter.new('bible_till_june.csv', 'seed_files_3')
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
end