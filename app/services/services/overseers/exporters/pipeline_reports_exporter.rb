class Services::Overseers::Exporters::PipelineReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @custom_statuses = Inquiry.pipeline_statuses
    @export_name = [@params.present? ? @params['date_range'] : 'Overall', 'Pipeline Report'].join(' ')
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Month',
        'New Inquiry Count',
        'New Inquiry Amount',
        'Ack Mail Count',
        'Ack Mail Amount',
        'Cross Ref Count',
        'Cross Ref Amount',
        'Preparing Quotation Count',
        'Preparing Quotation Amount',
        'Quotation Sent Count',
        'Quotation Sent Amount',
        'Follow Up on Quotation Count',
        'Follow Up on Quotation Amount',
        'Expected Order Count',
        'Expected Order Amount',
        'Pending Cust PO Revision Count',
        'Pending Cust PO Revision Amount',
        'Pending Manager Approval Count',
        'Pending Manager Approval Amount',
        'Pending Accounts Approval Count',
        'Pending Accounts Approval Amount',
        'Order Won Count',
        'Order Won Amount',
        'Rejected Sales Manager Count',
        'Rejected Sales Manager Amount',
        'Rejected by Accounts Count',
        'Rejected by Accounts Amount',
        'Order Lost Count',
        'Order Lost Amount',
        'Regret Count',
        'Regret Amount',
        'Grand Total Count',
        'Grand Total Amount',
        'Won %'
    ]

  end

  def call
    perform_export_later('PipelineReportsExporter', @arguments)
  end

  def build_csv

    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |month, record_bucket|
    @custom_statuses
    a = {month: format_month_without_date(month)}
    @custom_statuses.each do |index, status|
      a[index.to_s + 'count'] = record_bucket['pipeline']['buckets'].map {|bucket| bucket['doc_count'] if bucket['key'] == status}.compact.first || 0
      a[status.to_s+'value'] = record_bucket['pipeline']['buckets'].map {|bucket| bucket['inquiry_value']['value'] if bucket['key'] == status}.compact.first || 0
    end
    a['count'] = record_bucket['doc_count']
    a['value'] = record_bucket['sum_monthly_sales']['value']
    a['won'] = record_bucket['sum_monthly_sales']['value']!= 0 ? percentage((((record_bucket['pipeline']['buckets'].map {|bucket| bucket['inquiry_value']['value'] if bucket['key'] == 18}.compact.first || 0) / record_bucket['sum_monthly_sales']['value']) * 100).round(2)) : 0
      rows.push(a)
    end
    export = Export.create!(export_type: 93, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
