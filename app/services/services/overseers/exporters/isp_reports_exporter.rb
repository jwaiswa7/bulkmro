class Services::Overseers::Exporters::IspReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Overseer
    @category = @params.present? ? (@params['category'] == 'company_key' ? 'Company' : 'Inside Sales') : 'Inside Sales'
    @export_name = [@params.present? ? @params['date_range'] : '', 'ISP Report'].join(' ')
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Name',
        'No. of Inquiries',
        'No. of Sales Quotes',
        'No. of Sales Orders',
        'No. of Purchase Orders',
    ]
    # @export.update_attributes(export_type: 90, status: 'Enqueued')
  end

  def call
    # perform_export_later('IspReportsExporter', @arguments)
    ApplicationExportJob.perform_now('IspReportsExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name, true, @export_time).deliver_now
    @export = Export.create!(export_type: 105, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    if @indexed_records.present?
      records = @indexed_records
    else
      records = []
    end
    @indexed_records.each do |record|
      rows.push(
        name: record[:name],
        inquiries_count: record[:inquiries_count],
        sales_quotes_count: record[:sales_quotes_count],
        sales_orders_count: record[:sales_orders_count],
        purchase_orders_count: record[:purchase_orders_count]
      )
    end
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
