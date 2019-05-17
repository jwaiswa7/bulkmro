class Services::Overseers::LogisticsScorecards::OverallSummary < Services::Shared::BaseService
  def initialize(params, current_overseer)
    @params = params
    @current_overseer = current_overseer
  end

  def call
    service = Services::Overseers::Finders::LogisticsScorecards.new(@params, @current_overseer)
    service.call
    indexed_sales_invoices = service.indexed_records
    @months = indexed_sales_invoices.aggregations["logistics_scorecard_filter"]["buckets"]["custom-range"]["overall_scorecard"]["buckets"].keys.map{|key| Date.parse(key).strftime("%b %Y")}
    @records = indexed_sales_invoices.aggregations["logistics_scorecard_filter"]["buckets"]["custom-range"]["overall_scorecard"]["buckets"]
  end

  attr_accessor :months, :records
end
