class Services::Overseers::Exporters::SalesOrdersExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super
    @model = SalesOrder
    @export_name = 'sales_orders'
    @path = Rails.root.join('tmp', filename)
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
  end

  def call
    perform_export_later('SalesOrdersExporter')
  end

  def build_csv
    model.remote_approved.where.not(sales_quote_id: nil).where(:mis_date => start_at..end_at).each do |sales_order|
      inquiry = sales_order.inquiry

      rows.push({
                    :inquiry_number => inquiry.try(:inquiry_number) || "",
                    :order_number => sales_order.order_number,
                    :order_date => sales_order.created_at.to_date.to_s,
                    :company_alias => inquiry.try(:account).try(:name),
                    :company_name => inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : "",
                    :gt_exc => (sales_order.calculated_total == 0) ? (sales_order.calculated_total == nil ? 0 : '%.2f' % sales_order.calculated_total) : ('%.2f' % sales_order.calculated_total),
                    :tax_amount => ('%.2f' % sales_order.calculated_total_tax if sales_order.inquiry.present?),
                    :gt_inc => ('%.2f' % sales_order.calculated_total_with_tax if sales_order.inquiry.present?),
                    :status => sales_order.remote_status,
                    :inside_sales => sales_order.inside_sales_owner.to_s,
                    :outside_sales => sales_order.outside_sales_owner.to_s,
                    :quote_type => inquiry.try(:quote_category) || "",
                    :opportunity_type => inquiry.try(:opportunity_type) || "",
                }) if inquiry.present?
    end
    export = Export.create!(export_type: 40)
    generate_csv(export)
  end
end