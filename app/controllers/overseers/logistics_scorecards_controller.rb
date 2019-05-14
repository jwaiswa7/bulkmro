class Overseers::LogisticsScorecardsController < Overseers::BaseController

  def index
    authorize :logistics_scorecard
    respond_to do |format|
      format.html {}
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
end
