class Customers::ReportsController < Customers::BaseController

  def index
    authorize :report, :show?
    graph
  end

  def graph
    authorize :report, :show?

    @report = {
        "daterange": (params['daterange'] || ''),
        "report": params['action']
    }
    debugger
    if ([params['action']] & ['monthly_purchase_data','orders_count']).empty?
      service  = Services::Customers::Charts::MonthlyPurchaseData.new(@report)
      @chart = service.call(current_company)

      render 'monthly_purchase_data'
    else
      service = ['Services', 'Overseers', 'Reports', params['action']].join('::').constantize.send(:new, @report)
      @data = service.call(current_company)

      render params['action']
    end
  end

  # def monthly_purchase_data
  #   authorize :report, :show?
  #
  #   service  = Services::Customers::Charts::MonthlyPurchaseData.new
  #   @chart = service.call(current_company)
  # end
  #
  # def revenue_trend
  #   authorize :report, :show?
  #
  #   service  = Services::Customers::Charts::RevenueTrend.new
  #   @chart = service.call(current_company)
  # end
  #
  # def orders_count
  #   authorize :report, :show?
  #
  #   service  = Services::Customers::Charts::OrdersCount.new
  #   @chart = service.call(current_company)
  # end
  #
  # def unique_skus
  #   authorize :report, :show?
  #
  #   service  = Services::Customers::Charts::UniqueSkus.new
  #   @chart = service.call(current_company)
  # end
  #
  # def categorywise_revenue
  #   authorize :report, :show?
  #
  #   service  = Services::Customers::Charts::CategoryWiseRevenue.new
  #   @chart = service.call(current_company)
  # end
end