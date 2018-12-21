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

      sales_orders.group_by_month(&:created_at).map {|k, v| [k, v.map(&:calculated_total).sum]}.each do |month, revenue|
        @data[:labels].push(month.strftime("%b-%y"))
        @data[:datasets][1][:data].push(revenue)
      end

      sales_orders.joins(:products).group_by_month('sales_orders.created_at').count.each do |sales_order, products_count|
        @data[:datasets][0][:data].push(products_count)
      end
    end
  end
end