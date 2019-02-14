

class Customers::ReportsController < Customers::BaseController
  def monthly_purchase_data
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::MonthlyPurchaseData.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company)

    render 'monthly_purchase_data'
  end

  def revenue_trend
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::RevenueTrend.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company)

    render 'revenue_trend'
  end

  def unique_skus
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::UniqueSkus.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company)

    render 'unique_skus'
  end

  def order_count
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::OrderCount.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company)

    render 'order_count'
  end

  def categorywise_revenue
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::CategorywiseRevenue.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company)

    render 'categorywise_revenue'
  end
end
