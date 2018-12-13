class Services::Customers::Charts::MixedChart < Services::Shared::Charts::ChartConfig
  def initialize
    super
  end

  def customers_purchase_data(current_company)
    mixed_chart

    ActiveRecord::Base.default_timezone = :utc

    so = SalesOrder.includes(:rows).remote_approved.where(:created_at => start_at..end_at).joins(:company).where(companies: {id: current_company.id})
    so.group_by_month(&:created_at).map{|k,v| [k, v.map(&:calculated_total).sum] }.each do |month, revenue|
      @data[:labels].push(month)
      @data[:datasets][1][:data].push(revenue)
    end
    so.joins(:products).group_by_month('sales_orders.created_at').count.each do |order, products_count|
      @data[:datasets][0][:data].push(products_count)
    end
    ActiveRecord::Base.default_timezone = :local

    @chart.push(@data, @options)
  end
end