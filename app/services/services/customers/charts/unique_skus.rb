class Services::Customers::Charts::UniqueSkus < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "Sku Count",
                  type: "bar",
                  borderColor: "#fd7e14",
                  backgroundColor: '#fd7e14',
                  data: [],
                  yAxisID: 'sku_count',
                  fill: false
              }
          ]
      }

      @options = {
          scales: {
              yAxes: [
                  {
                      id: 'sku_count',
                      type: 'linear',
                      position: 'left',
                      ticks: {
                          display: true,
                          userCallback: ''
                      },
                      scaleLabel: {
                          display: true,
                          labelString: 'Sku Count'
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(:created_at => start_at..end_at).joins(:company).where(companies: {id: company.id})
      ordered_products = sales_orders.joins(:products)

      (start_at..end_at).map {|a| a.strftime("%b-%Y") }.uniq.each do |month|
        @data[:labels].push(month.gsub(/-(\d{2})/, '-'))
        @data[:datasets][0][:data].push(ordered_products.where('sales_orders.created_at' => month.to_date.beginning_of_month..month.to_date.end_of_month.end_of_day).map{|so| so.products}.flatten.uniq.count)
      end
    end
  end

  attr_accessor :start_at, :end_at
end