class Services::Customers::Exporters::AmatCustomersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(headers, company)
    @filename = 'export_amat_customer_details'
    super(headers, @filename)
    @company = company
    @export_name = 'amat_customer_portal'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry Number','Inquiry Date','BM Number','Descripton','Location','Transaction Type','AMAT Request Date','AMAT Request Number','Bulk MRO Quotation Date','Order Confirmation Date by Email','AMAT PO Number','Actual PO received from AMAT Date','PO from Bulk MRO to Vendor Date','PI from Vendor Date','Payment made to Vendor date','Committed Date by Bulk MRO','Revised Committed Date','Actual Delivery Date','PO Status','Tracking Number','Invoice Date','Invoice No','Material Dispatch Date','Comments']
  end


  def call
    build_csv
  end

  def build_csv
    company = @company

    records = company.inquiries.where(:created_at => Date.parse("2018-11-01 00:00:00")..(Date.today))

    records.each do |inquiry|
      if inquiry.sales_orders.present?
        inquiry.sales_orders.each do |sale_order|
          if sale_order.invoices.present?
            sale_order.invoices.each do |invoice|
                invoice.rows.each do |row|
                  if inquiry.purchase_orders.present?
                    po_ids = inquiry.purchase_orders.pluck(:id)
                    po_products = PurchaseOrderRow.where(purchase_order_id: po_ids)
                    po = po_products.where("metadata->>'PopProductId' = ?",row.metadata['product_id'].to_s)
                  end

                  rows.push(
                      inquiries: inquiry.inquiry_number.present? ? inquiry.inquiry_number : '-',
                      inquiry_date: inquiry.created_at.present? ? format_date(inquiry.created_at) : '-',
                      bm_number:  row.sku.present? ? row.sku : '-',
                      description: row.name.present? ? row.name : '-',
                      location: inquiry.billing_address.city_name.present? ? inquiry.billing_address.city_name : '-',
                      transaction_type: (inquiry.billing_address.country_code.present? && (inquiry.billing_address.country_code == 'IN')) ? 'Domestic' : 'International',
                      amat_request_date:'-',
                      amt_request_no:'-',
                      quotation_date: inquiry.quotation_date.present? ? format_date(inquiry.quotation_date) : '-',
                      order_confirmation_date_by_email: inquiry.customer_order_date.present? ? format_date(inquiry.customer_order_date) : '-',
                      amat_po_number: inquiry.customer_po_number.present? ? inquiry.customer_po_number : '-',
                      actual_po_recieved_from_amat_date: inquiry.customer_po_received_date.present? ? format_date(inquiry.customer_po_received_date) : '-',
                      po_from_bulkmro_to_vendor_date: (inquiry.purchase_orders.present? && po.present?) ? format_date(po.first.purchase_order.created_at) : '-',
                      pi_from_vendor_date: '-',
                      payment_made_to_vendor:'-',
                      commited_date_by_bulkmro: inquiry.customer_committed_date.present? ? format_date(inquiry.customer_committed_date) : '-',
                      revised_committed_date:'-',
                      actual_delivery_date:'-',
                      po_status: '-',
                      tracking_number:'-',
                      invoice_date: format_date(invoice.created_at),
                      invoice_number: invoice.invoice_number,
                      material_dispatch_date:'-',
                      comments:'-'
                  )
                end
            end
          else
            sale_order.products.each do |so_product|
              rows.push(
                          inquiries: inquiry.inquiry_number.present? ? inquiry.inquiry_number : '-',
                          inquiry_date: inquiry.created_at.present? ? format_date(inquiry.created_at) : '-',
                          bm_number: so_product.present? ? so_product.sku : '-',
                          description: so_product.present? ? so_product.name : '-',
                          location: inquiry.billing_address.city_name.present? ? inquiry.billing_address.city_name : '-',
                          transaction_type: (inquiry.billing_address.country_code.present? && (inquiry.billing_address.country_code == 'IN')) ? 'Domestic' : 'International',
                          amat_request_date:'-',
                          amt_request_no:'-',
                          quotation_date: inquiry.quotation_date.present? ? format_date(inquiry.quotation_date) : '-',
                          order_confirmation_date_by_email: inquiry.customer_order_date.present? ? format_date(inquiry.customer_order_date) : '-',
                          amat_po_number: inquiry.customer_po_number.present? ? inquiry.customer_po_number : '-',
                          actual_po_recieved_from_amat_date: inquiry.customer_po_received_date.present? ? format_date(inquiry.customer_po_received_date) : '-',
                          po_from_bulkmro_to_vendor_date:'-',
                          pi_from_vendor_date: '-',
                          payment_made_to_vendor:'-',
                          commited_date_by_bulkmro: inquiry.customer_committed_date.present? ? format_date(inquiry.customer_committed_date) : '-',
                          revised_committed_date:'-',
                          actual_delivery_date:'-',
                          po_status: '-',
                          tracking_number:'-',
                          invoice_date: '-',
                          invoice_number: '-',
                          material_dispatch_date:'-',
                          comments:'-'
                      )
            end
          end
          end
        end
      end
    export = Export.create!(export_type: 97, filtered: false)
    generate_csv(export)
  end

end
