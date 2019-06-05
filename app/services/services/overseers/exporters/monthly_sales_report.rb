class Services::Overseers::Exporters::MonthlySalesReport < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Report
    @export_name = 'monthly_sales_report'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Month', 'inquiry count', 'sales order count', 'total', 'products count', 'product quantities' ]
  end

  def call
    perform_export_later('MonthlySalesReport', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end

    records.entries.each do |key, value|
      if key.class != Symbol
        data = {record: format_month_without_date(key)}
        entries = data.merge value
        rows.push(entries)
      end
    end
    export = Export.create!(export_type: 94, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
