class Overseers::LogisticsScorecardsController < Overseers::BaseController

  def index
    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::LogisticsScorecards.new(params, current_overseer, paginate: false)
        service.call
        indexed_sales_orders = service.indexed_records
        @sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders).call
        @per = (params['per'] || params['length'] || 20).to_i
        @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
        @logistics_scorecard_records = Kaminari.paginate_array(@sales_orders).page(@page).per(@per)
      end
    end
  end
end
