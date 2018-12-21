class Services::Customers::Charts::Builder < Services::Shared::Charts::Builder
  def initialize
    super
  end

  def monthly_purchase_data(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "Products",
                  type: "line",
                  borderColor: "#ff0000",
                  backgroundColor: "#ff0000",
                  data: [],
                  yAxisID: 'products_count',
                  fill: false
              },
              {
                  label: "Orders",
                  type: "bar",
                  borderColor: "#8e5ea2",
                  backgroundColor: '#50BB70',
                  data: [],
                  yAxisID: 'revenue',
                  fill: false,
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
                  },
                  {
                      id: 'revenue',
                      type: 'linear',
                      position: 'left',
                      ticks: {
                          display: true,
                          userCallback: ''
                      },
                      scaleLabel: {
                          display: true,
                          labelString: 'Total Spends'
                      }
                  }
              ]
          }
      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(:created_at => start_at..end_at).joins(:company).where(companies: {id: company.id})
      monthwise_order_totals = sales_orders.group_by_month(&:created_at).map {|k, v| [k.strftime("%b-%y"), v.map(&:calculated_total).sum.to_s]}.to_h
      monthwise_products_count = sales_orders.joins(:products).group_by_month('sales_orders.created_at', format: "%b-%y", series:true).count.to_h

      (start_at..end_at).map {|a| a.strftime("%b-%y")}.uniq.each do |month|
        @data[:labels].push(month)
        @data[:datasets][1][:data].push(monthwise_order_totals[month] || 0)
        @data[:datasets][0][:data].push(monthwise_products_count[month] || 0)
      end
    end
  end
end