class Services::Customers::Charts::OrderCount < Services::Customers::Charts::Builder
  def initialize(daterange, company_id)
    super
  end

  def call(account)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: 'Order Count',
                  type: 'bar',
                  borderColor: '#fd7e14',
                  backgroundColor: '#fd7e14',
                  data: [],
                  yAxisID: 'order_count',
                  fill: false
              }
          ]
      }

      @options = {
          scales: {
              yAxes: [
                  {
                      id: 'order_count',
                      type: 'linear',
                      position: 'left',
                      ticks: {
                          display: true,
                          userCallback: '',
                          beginAtZero: true
                      },
                      scaleLabel: {
                          display: true,
                          labelString: 'Order Count'
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.remote_approved.where(created_at: start_at..end_at).joins(:account).joins(:company).where(accounts: {id: account.id})
      sales_orders = sales_orders.where(companies: {id: @company_id.to_i}) unless @company_id.nil?

      sales_orders.group_by_quarter('sales_orders.created_at', format: '%b-%Y', series: true).size.each do |quarter_start, order_count|
        @data[:labels].push(get_quarter(quarter_start.to_date))
        @data[:datasets][0][:data].push(order_count)
      end
    end
  end

  attr_accessor :start_at, :end_at, :company_id
end
