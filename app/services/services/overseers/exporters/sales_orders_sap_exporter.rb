

class Services::Overseers::Exporters::SalesOrdersSapExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @start_at = Time.now.beginning_of_month
    @model = SalesOrder
    @export_name = 'sales_order_sap'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Region',
                'Inquiry Number',
                'SO Number',
                'SO Booking Date',
                'Inside Sales',
                'Outside Sales',
                'Company Alias',
                'Company Name',
                'Client PO Date',
                'Client PO Number',
                'Selling Value (Excluding Tax)',
                'Selling Value (Including Tax)',
                'Margin Amount',
                'Order Type (BMRO/ONG)'
    ]
  end

  def call
    perform_export_later('SalesOrdersSapExporter')
  end

  def build_csv
    model.remote_approved.where.not(sales_quote_id: nil).where(mis_date: start_at..end_at).order(mis_date: :desc).each do |sales_order|
      inquiry = sales_order.inquiry
      rows.push(
        region: '',
        inquiry_number: inquiry.inquiry_number,
        order_number: sales_order.order_number,
        booking_date: sales_order.created_at.to_date.to_s,
        inside_sales: sales_order.inside_sales_owner.try(:full_name),
        outside_sales: sales_order.outside_sales_owner.try(:full_name),
        company_alias: inquiry.account.name,
        company_name: inquiry.company.name,
        client_po_date: inquiry.customer_order_date.to_s,
        client_po_number: inquiry.customer_po_number,
        selling_value_without_tax: ('%.2f' % sales_order.calculated_total),
        selling_value_with_tax: ('%.2f' % sales_order.calculated_total_with_tax),
        margin_amount: ('%.2f' % sales_order.calculated_total_margin),
        order_type: inquiry.quote_category
                )
    end
    export = Export.create!(export_type: 50)
    generate_csv(export)
  end
end
