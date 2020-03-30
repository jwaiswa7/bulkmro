class Services::Overseers::Exporters::SalesOrdersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = SalesOrder
    @export_name = 'sales_orders'
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Inquiry Number',
        'Order Number',
        'Order Date',
        'Mis Date',
        'Company Name',
        'Company Alias',
        'Order Net Amount',
        'Order Tax Amount',
        'Order Total Amount',
        'Order Status',
        'Inside Sales',
        'Outside Sales',
        'Sales Manager',
        'Quote Type',
        'Opportunity Type',
        'Total Marging'
    ]
  end

  def call
    perform_export_later('SalesOrdersExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
    if @ids.present?
      records = model.where(id: @ids).remote_approved.order_not_deleted.where.not(sales_quote_id: nil).order(mis_date: :desc)
    else
      records = model.remote_approved.order_not_deleted.where.not(sales_quote_id: nil).where(mis_date: start_at..end_at).order(mis_date: :desc)
    end
    @export = Export.create!(export_type: 40, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    records.find_each(batch_size: 200) do |sales_order|
      inquiry = sales_order.inquiry

      rows.push(
        inquiry_number: inquiry.try(:inquiry_number) || '',
        order_number: sales_order.order_number,
        order_date: sales_order.created_at.to_date.to_s,
        mis_date: sales_order.mis_date.to_date.to_s,
        company_alias: inquiry.try(:account).try(:name),
        company_name: inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : '',
        gt_exc: (sales_order.calculated_total == 0) ? (sales_order.calculated_total == nil ? 0 : '%.2f' % sales_order.calculated_total) : ('%.2f' % sales_order.calculated_total),
        tax_amount: ('%.2f' % sales_order.calculated_total_tax if sales_order.inquiry.present?),
        gt_inc: ('%.2f' % sales_order.calculated_total_with_tax if sales_order.inquiry.present?),
        status: sales_order.remote_status,
        inside_sales: sales_order.inside_sales_owner.try(:full_name),
        outside_sales: sales_order.outside_sales_owner.try(:full_name),
        sales_manager: inquiry.sales_manager.full_name,
        quote_type: inquiry.try(:quote_category) || '',
        opportunity_type: inquiry.try(:opportunity_type) || '',
        total_margin: sales_order.calculated_total_margin
                ) if inquiry.present?
    end
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
