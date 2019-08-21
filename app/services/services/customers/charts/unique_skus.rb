class Services::Customers::Charts::UniqueSkus < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(account)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: 'SKU Count',
                  type: 'bar',
                  borderColor: '#007bff',
                  backgroundColor: '#007bff',
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
                          userCallback: '',
                          beginAtZero: true
                      },
                      scaleLabel: {
                          display: true,
                          labelString: 'SKU Count'
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(created_at: start_at..end_at).joins(:account).where(accounts: { id: account.id })
      ordered_products = sales_orders.joins(:products)

      (start_at..end_at).map { |a| a.strftime('%b-%Y') }.uniq.map { |month| month.to_date.beginning_of_quarter }.uniq.each do |quarter|
        @data[:labels].push("#{quarter.to_date.strftime('%b/%y')} - #{quarter.to_date.end_of_quarter.strftime('%b/%y')}")
        @data[:datasets][0][:data].push(ordered_products.where('sales_orders.created_at' => quarter.to_date.beginning_of_month..quarter.to_date.end_of_month.end_of_day).map{ |so| so.products }.flatten.uniq.count)
      end
    end
  end

  attr_accessor :start_at, :end_at
end
