class Services::Customers::Charts::UniqueSkus < Services::Customers::Charts::Builder
  def initialize
    super
    # @start_at = start_at
    # @end_at = end_at
  end

  def call(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "Sku Counts",
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
                          labelString: 'Sku Counts'
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

      (start_at..end_at).map {|a| a.strftime("%b-%y") }.uniq.each do |month|
        @data[:labels].push(month)
        @data[:datasets][0][:data].push(ordered_products.where('sales_orders.created_at' => month.to_date.beginning_of_month..month.to_date.end_of_month).map{|so| so.products}.flatten.uniq.count)
      end
    end
  end

  attr_accessor :start_at, :end_at
end