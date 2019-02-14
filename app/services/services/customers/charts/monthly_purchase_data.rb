# frozen_string_literal: true

class Services::Customers::Charts::MonthlyPurchaseData < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(company)
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
                          display: false
                      }
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
                          labelString: '₹ Lacs'
                      },
                      gridLines: {
                          display: true
                      }
                  }
              ]
          },
      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(created_at: start_at..end_at).joins(:company).where(companies: { id: company.id })
      monthwise_order_totals = sales_orders.group_by_month(&:created_at).map { |k, v| [k.strftime('%b-%y'), v.map(&:calculated_total).sum.to_s] }.to_h
      monthwise_products_count = sales_orders.joins(:products).group_by_month('sales_orders.created_at', format: '%b-%y', series: true).count.to_h

      (start_at..end_at).map { |a| a.strftime('%b-%y') }.uniq.each do |month|
        @data[:labels].push(month)
        @data[:datasets][1][:data].push(monthwise_order_totals[month] || 0)
        @data[:datasets][0][:data].push(monthwise_products_count[month] || 0)
      end
    end
  end

  attr_accessor :start_at, :end_at
end
