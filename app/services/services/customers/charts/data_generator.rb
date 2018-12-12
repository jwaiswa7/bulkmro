class Services::Customers::Charts::DataGenerator < Services::Shared::Charts::ChartConfig
  def initialize
    super
  end

  def get_multi_axis_mixed_chart
    super

    start_at = Date.new(2018, 04, 01)
    end_at = Time.now.end_of_month
    revenue_data = []
    months = []
    products_count = []

    ActiveRecord::Base.default_timezone = :utc

    so = SalesOrder.remote_approved.joins(:rows).distinct.where(:created_at => start_at..end_at)
    so.group_by_month(&:created_at).map{|k,v| [k, v.map(&:calculated_total).sum] }.each do |month, revenue|
      months.push(month)
      revenue_data.push(revenue)
    end
    so.group_by_month('sales_orders.created_at').count.each do |order, product_count|
      products_count.push(product_count)
    end
    ActiveRecord::Base.default_timezone = :local


    @data[:labels] = months
    months.each_with_index do |m, index|
      @data[:datasets][0][:data].push(products_count[index])
      @data[:datasets][1][:data].push(revenue_data[index])
    end
    @chart.push(@data, @options)
  end
end