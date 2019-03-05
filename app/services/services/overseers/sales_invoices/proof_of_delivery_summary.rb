class Services::Overseers::SalesInvoices::ProofOfDeliverySummary < Services::Shared::BaseService
  def initialize(params, current_overseer)
    @params = params
    @current_overseer = current_overseer
  end

  def call
    service = Services::Overseers::Finders::SalesInvoices.new(@params, @current_overseer)
    service.call
    indexed_sales_invoices = service.indexed_records

    @invoice_over_month = indexed_sales_invoices.aggregations['invoice_over_time']['buckets']
    pod_over_month_histogram = indexed_sales_invoices.aggregations['pod_over_time']['buckets']
    @list_of_months = @invoice_over_month.map{|i| i['key_as_string']}
    @pod_over_month = {}
    pod_over_month_histogram.map{|p| @pod_over_month[p['key_as_string']]=p['doc_count']}
  end

  attr_accessor :invoice_over_month, :pod_over_month, :list_of_months
end
