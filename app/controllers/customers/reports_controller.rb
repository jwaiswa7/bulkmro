class Customers::ReportsController < Customers::BaseController
  def quarterly_purchase_data
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::QuarterlyPurchaseData.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company.account)

    render 'quarterly_purchase_data'
  end

  def revenue_trend
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::RevenueTrend.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company.account)

    render 'revenue_trend'
  end

  def unique_skus
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::UniqueSkus.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company.account)

    render 'unique_skus'
  end

  def order_count
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::OrderCount.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company.account)

    render 'order_count'
  end

  def categorywise_revenue
    authorize :report, :show_aggregate_reports?

    service = Services::Customers::Charts::CategorywiseRevenue.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company.account)

    render 'categorywise_revenue'
  end

  def stock_reports
    authorize :report
    account = Account.find(2431)
    if account.present?
      @warehouse_products = ApplyDatatableParams.to(WarehouseProductStock.where(warehouse_id: 32).order(instock: :desc), params)
    end
  end
end
