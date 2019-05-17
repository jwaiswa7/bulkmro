class Overseers::LogisticsScorecardsController < Overseers::BaseController

  def index
    authorize :logistics_scorecard
    respond_to do |format|
      format.html {
        service = Services::Overseers::LogisticsScorecards::OverallSummary.new(params, current_overseer)
        service.call
        @months = service.months
        @records = service.records
      }
      format.json do
        service = Services::Overseers::Finders::LogisticsScorecards.new(params, current_overseer, paginate: false)
        service.call
        indexed_sales_invoices = service.indexed_records
        @sales_invoices = Services::Overseers::SalesOrders::FetchLogisticsScorecardsData.new(indexed_sales_invoices).call
        @per = (params['per'] || params['length'] || 20).to_i
        @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
        @logistics_scorecard_records = Kaminari.paginate_array(@sales_invoices).page(@page).per(@per)
      end
    end
  end

  def add_delay_reason
    authorize :logistics_scorecard
    SalesInvoice.where(id: params[:invoice_id]).update_all(delay_reason: params[:selected].to_i)
    LogisticsScorecardsIndex::SalesInvoice.import SalesInvoice.where(id: params[:invoice_id])
    redirect_to overseers_logistics_scorecards_path, notice: 'Delay Reason Updated'
  end

  def update
    authorize :logistics_scorecard

  end
end
