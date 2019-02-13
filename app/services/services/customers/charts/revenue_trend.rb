

class Services::Customers::Charts::RevenueTrend < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "₹ Lacs",
                  type: "bar",
                  borderColor: "#fd7e14",
                  backgroundColor: "#fd7e14",
                  data: [],
                  yAxisID: "revenue",
                  fill: false
              }
          ]
      }

      @options = {
          scales: {
              yAxes: [
                  {
                      id: "revenue",
                      type: "linear",
                      position: "left",
                      ticks: {
                          display: true,
                          userCallback: ""
                      },
                      scaleLabel: {
                          display: true,
                          labelString: "₹ Lacs"
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(created_at: start_at..end_at).joins(:company).where(companies: { id: company.id })
      monthwise_order_totals = sales_orders.group_by_month(&:created_at).map { |k, v| [k.strftime("%b-%y"), v.map(&:calculated_total).sum.to_s] }.to_h

      (start_at..end_at).map { |a| a.strftime("%b-%y") }.uniq.each do |month|
        @data[:labels].push(month)
        @data[:datasets][0][:data].push(monthwise_order_totals[month] || 0)
      end
    end
  end

  attr_accessor :start_at, :end_at
end
