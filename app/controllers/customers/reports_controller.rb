class Customers::ReportsController < Customers::BaseController

  def index
    authorize :report, :show?
    redirect_to monthly_purchase_data_customers_reports_path
  end

  def monthly_purchase_data
    authorize :report, :show?

    service  = Services::Customers::Charts::MonthlyPurchaseData.new
    @chart = service.call(current_company)
  end

  def revenue_trend
    authorize :report, :show?

    service  = Services::Customers::Charts::RevenueTrend.new
    @chart = service.call(current_company)
  end

  def orders_count
    authorize :report, :show?

    service  = Services::Customers::Charts::OrdersCount.new
    @chart = service.call(current_company)
  end

  def unique_skus
    authorize :report, :show?

    service  = Services::Customers::Charts::UniqueSkus.new
    @chart = service.call(current_company)
  end

  def categorywise_revenue
    authorize :report, :show?

    service  = Services::Customers::Charts::CategoryWiseRevenue.new
    @chart = service.call(current_company)
  end
end