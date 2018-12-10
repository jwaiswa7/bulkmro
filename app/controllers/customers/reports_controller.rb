class Customers::ReportsController < Customers::BaseController
  def quarterly_purchase_data
    authorize :report, :show?

    start_at = Date.new(2018, 04, 01)
    ActiveRecord::Base.default_timezone = :utc

    revenue_data = []
    months = []
    # inquiries = Inquiry.where(:status => "Order Won").where(:created_at => start_at..Time.now.end_of_quarter)
    # inquiries.group_by_month(:created_at).sum("calculated_total").each do |month, revenue|
    #   months.push(month)
    #   revenue_data.push(revenue)
    # end

    products_count = []
    so = SalesOrder.remote_approved.joins(:rows).distinct.where(:created_at => start_at..Time.now.end_of_quarter)
    so.group_by_month(&:created_at).map{|k,v| [k, v.map(&:calculated_total).sum] }.each do |month, revenue|
      months.push(month)
      revenue_data.push(revenue)
    end
    so.group_by_month('sales_orders.created_at').count.each do |order, product_count|
      products_count.push(product_count)
    end

    # for quarterwise reports
    # quarters = [[1,2,3], [4,5,6], [7,8,9], [10,11,12]]
    # quarter_months = quarters[(Time.now.month - 1) / 3]

    service  = Services::Customers::Charts::DataGenerator.new()
    @chart = service.get_multi_axis_mixed_chart(revenue_data, products_count, months)
  end
end

