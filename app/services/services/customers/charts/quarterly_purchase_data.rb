class Services::Customers::Charts::QuarterlyPurchaseData < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(account)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: 'Products',
                  type: 'line',
                  lineTension: 0,
                  borderColor: '#007bff',
                  backgroundColor: '#007bff',
                  data: [],
                  yAxisID: 'products_count',
                  fill: false
              },
              {
                  label: '₹ Lacs',
                  type: 'bar',
                  borderColor: '#fd7e14',
                  backgroundColor: '#fd7e14',
                  data: [],
                  yAxisID: 'revenue',
                  fill: false
              }
          ]
      }

      @options = {
          scales: {
              yAxes: [
                  {
                      id: 'products_count',
                      type: 'linear',
                      position: 'right',
                      ticks: {
                          display: false,
                          beginAtZero: true
                      }
                  },
                  {
                      id: 'revenue',
                      type: 'linear',
                      position: 'left',
                      ticks: {
                          display: true,
                          userCallback: '',
                          beginAtZero: true
                      },
                      scaleLabel: {
                          display: true,
                          labelString: '₹ Lacs'
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.remote_approved.where(created_at: start_at..end_at).joins(:account).where(accounts: {id: account.id})

      quarterwise_order_totals = sales_orders.group_by_quarter(&:created_at).map { |k, v| [k.strftime('%b-%y'), v.map(&:calculated_total).sum.to_s] }.to_h
      quarterwise_products_count = sales_orders.joins(:products).group_by_quarter('sales_orders.created_at', format: '%b-%y', series: true).count.to_h

      (start_at..end_at).map { |a| a.strftime('%b-%Y') }.uniq.map { |month| month.to_date.beginning_of_quarter }.uniq.each do |quarter_start|
        formatted_quarter_start = quarter_start.to_date.strftime('%b-%y')
        @data[:labels].push(get_quarter(quarter_start.to_date))
        @data[:datasets][1][:data].push(quarterwise_order_totals[formatted_quarter_start] || 0)
        @data[:datasets][0][:data].push(quarterwise_products_count[formatted_quarter_start] || 0)
      end
    end
  end

  attr_accessor :start_at, :end_at
end
