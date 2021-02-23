class Services::Overseers::Exporters::CompareCompaniesTotalforTCS < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Company
    @export_name = 'companies_total'
    @path = Rails.root.join('tmp', filename)
    @columns = header_columns
  end

  def call
    build_csv
  end

  def header_columns
    ['Companies', 'Actual Total', 'Recorded Total']
  end

  def build_csv
    @export_time['creation'] = Time.now
    records = Company.acts_as_customer.includes(:account).includes(:sales_orders)
    @export = Export.create!(export_type: 109, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id, status: 'Processing')
    start_date = Company.current_financial_year_start
    end_date = Company.current_financial_year_end
    records.find_each(batch_size: 100) do |record|
      recorded_total_For_tcs = CompanyTransactionsAmount.where(financial_year: Company.current_financial_year, company_id: record.id)
      rows.push(
        company_name: record.name,
        actual_total_amount: record.sales_orders.where(created_at: start_date..end_date).where(status: 'Approved').map(&:calculated_total_with_tax).compact.sum.to_f,
        recorded_total: (recorded_total_For_tcs.last.total_amount.to_f if recorded_total_For_tcs.present?)
      )
    end
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
