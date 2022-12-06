class Services::Customers::Charts::UniqueSkus < Services::Customers::Charts::Builder
  def initialize(daterange, company_id)
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

      sales_orders = SalesOrder.remote_approved.where(created_at: start_at..end_at).joins(:account).joins(:company).where(accounts: {id: account.id})
      sales_orders = sales_orders.where(companies: {id: @company_id.to_i}) unless @company_id.nil?
      ordered_products = sales_orders.joins(:products)

      (start_at..end_at).map { |a| a.strftime('%b-%Y') }.uniq.map { |month| month.to_date.beginning_of_quarter }.uniq.each do |quarter_start|
        @data[:labels].push(get_quarter(quarter_start.to_date))
        @data[:datasets][0][:data].push(ordered_products.where('sales_orders.created_at' => quarter_start.to_date.beginning_of_day..quarter_start.to_date.end_of_quarter.end_of_day).map{ |so| so.products }.flatten.uniq.count)
      end
    end
  end

  attr_accessor :start_at, :end_at, :company_id
end
