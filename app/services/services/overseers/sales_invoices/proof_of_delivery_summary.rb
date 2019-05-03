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
    @regular_pod_over_month = indexed_sales_invoices.aggregations['regular_pod_over_time']['buckets']
    @route_through_pod_over_month = indexed_sales_invoices.aggregations['route_through_pod_over_time']['buckets']
  end

  attr_accessor :invoice_over_month, :pod_over_month, :list_of_months, :regular_pod_over_month, :route_through_pod_over_month
end
