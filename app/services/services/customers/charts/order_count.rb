class Services::Customers::Charts::OrderCount < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "Order Count",
                  type: "bar",
                  borderColor: "#fd7e14",
                  backgroundColor: "#fd7e14",
                  data: [],
                  yAxisID: "order_count",
                  fill: false
              }
          ]
      }

      @options = {
          scales: {
              yAxes: [
                  {
                      id: "order_count",
                      type: "linear",
                      position: "left",
                      ticks: {
                          display: true,
                          userCallback: ""
                      },
                      scaleLabel: {
                          display: true,
                          labelString: "Order Count"
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(created_at: start_at..end_at).joins(:company).where(companies: { id: company.id })

      sales_orders.group_by_month("sales_orders.created_at", format: "%b-%y", series: true).size.each do |month, order_count|
        @data[:labels].push(month)
        @data[:datasets][0][:data].push(order_count)
      end
    end
  end

  attr_accessor :start_at, :end_at
end
