require 'net/scp'

class Services::Overseers::Reports::FlexFTPReport < Services::Overseers::Reports::BaseReport
  def initialize
    @company = Company.find(1847)
    @start_at = Date.today.last_week.beginning_of_week.beginning_of_day
    @end_at = Date.today.last_week.end_of_week.end_of_day
  end

  def call
    # Net::SSH.start(Settings.flex_ftp.host, Settings.flex_ftp.user_id, ssh: { password: Settings.flex_ftp.password }) do |ssh|
    #   path = flex_dump
    #   ssh.scp.upload!(path, '/in')
    # end

    Net::SCP.start('192.168.0.165', 'saurabh', { password: 'bulkmro', port: 21 }) do |ftp|
      puts 'SCP', ftp
      path = flex_dump
      ftp.scp.upload!(path, '/home/saurabh/Documents')
    end
  end

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

  def flex_dump
    column_headers = ['Order Date', 'Order ID', 'PO Number', 'Part Number', 'Account Gp', 'Line Item Quantity', 'Line Item Net Total', 'Account User Email', 'Shipping Address', 'Currency', 'Product Category', 'Part number Description']

    # total filters
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      flex_offline_orders = SalesOrder.joins(:company).where(companies: {id: company.id}).where(created_at: start_at..end_at).order(name: :asc)
      flex_offline_orders.each do |order|
        if !order.inquiry.customer_order.present?
          order.rows.each do |record|
            sales_order = record.sales_order
            order_date = sales_order.inquiry.customer_order_date.strftime('%F')
            order_id = sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.online_order_number : ''
            customer_po_number = sales_order.inquiry.customer_po_number
            part_number = record.product.sku
            account = sales_order.inquiry.company.name

            line_item_quantity = record.quantity
            line_item_net_total = record.total_selling_price.to_s
            user_email = sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.contact.email : 'sivakumar.ramu@flex.com'
            shipping_address = sales_order.inquiry.shipping_address
            currency = sales_order.inquiry.inquiry_currency.currency.name
            category = record.product.category.name
            part_number_description = record.product.name

            writer << [order_date, order_id, customer_po_number, part_number, account, line_item_quantity, line_item_net_total, user_email, shipping_address, currency, category, part_number_description]
          end
        end
      end

      flex_online_orders = CustomerOrder.joins(:company).where(companies: {id: company.id}).where(created_at: start_at..end_at).order(name: :asc)
      flex_online_orders.each do |customer_order|
        customer_order.rows.each do |record|
          inquiry = customer_order.inquiry
          order_date = customer_order.created_at.strftime('%F')
          order_id = customer_order.online_order_number
          customer_po_number = inquiry.present? ? inquiry.customer_po_number : ''
          part_number = record.product.sku
          account = customer_order.company_id.to_s

          line_item_quantity = record.quantity
          line_item_net_total = '' # record.total_selling_price.to_s
          user_email = Contact.find(customer_order.contact_id).email.to_s
          shipping_address = Address.find(customer_order.shipping_address_id).to_s
          currency = inquiry.present? ? inquiry.inquiry_currency.currency.name : ''
          category = record.product.category.name
          part_number_description = record.product.name

          writer << [order_date, order_id, customer_po_number, part_number, account, line_item_quantity, line_item_net_total, user_email, shipping_address, currency, category, part_number_description]
        end
      end
    end

    filename = [Date.today.strftime('%m%d%Y'), '.xlsx'].join
    fetch_csv(filename, csv_data)
  end

  attr_accessor :start_at, :end_at, :company
end
