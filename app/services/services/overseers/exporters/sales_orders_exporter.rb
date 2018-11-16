class Services::Overseers::Exporters::SalesOrdersExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = [
        'Inquiry Number',
        'Order Number',
        'Order Date',
        'Company Name',
        'Company Alias',
        'Order Net Amount',
        'Order Tax Amount',
        'Order Total Amount',
        'Order Status',
        'Inside Sales',
        'Outside Sales',
        'Quote Type',
        'Opportunity Type'
    ]

    @model = SalesOrder
  end

  def call
    model.status_Approved.where(:created_at => start_at..end_at).each do |sales_order|
      inquiry = sales_order.inquiry
      
      rows.push({
                    :inquiry_number => inquiry.try(:inquiry_number) || "",
                    :order_number => sales_order.order_number,
                    :order_date => sales_order.created_at.to_date.to_s,
                    :company_alias => inquiry.try(:account).try(:name),
                    :company_name => inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : "",
                    :gt_exc => (sales_order.calculated_total == 0) ? (sales_order.report_total == nil ? 0 : '%.2f' % sales_order.report_total) : ('%.2f' % sales_order.calculated_total),
                    :tax_amount => ('%.2f' % sales_order.calculated_total_tax),
                    :gt_inc => ('%.2f' % sales_order.calculated_total_with_tax),
                    :status => sales_order.remote_status,
                    :inside_sales => sales_order.inside_sales_owner.to_s,
                    :outside_sales => sales_order.outside_sales_owner.to_s,
                    :quote_type => inquiry.try(:quote_category) || "",
                    :opportunity_type => inquiry.try(:opportunity_type) || "",
                })
    end

    generate_csv
  end
end