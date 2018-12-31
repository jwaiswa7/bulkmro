class Services::Customers::Charts::CategoryWiseRevenue < Services::Customers::Charts::Builder
  def initialize(daterange)
    super
  end

  def call(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "Categorywise Revenue",
                  type: "doughnut",
                  borderColor: "#fd7e14",
                  backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f","#e8c3b9","#c45850", '#fd7e14'],
                  data: [],
              }
          ]
      }

      @options = {

      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(:created_at => start_at..end_at).joins(:company).where(companies: {id: company.id}).joins(:products)
      total_revenue = sales_orders.map {|so| so.calculated_total }.sum
      categorywise_revenue = {}

      sales_orders.each do |so|
        so.rows.each do |row|
          if row.product.category.ancestors.present?
            categorywise_revenue[row.product.category.ancestors.third_to_last.name] ||= 0
            categorywise_revenue[row.product.category.ancestors.third_to_last.name] = categorywise_revenue[row.product.category.ancestors.third_to_last.name] + row.total_selling_price
          else
            categorywise_revenue[row.product.category.name] ||= 0
            categorywise_revenue[row.product.category.name] = categorywise_revenue[row.product.category.name] + row.total_selling_price
          end
        end
      end
      categorywise_revenue.each do |category|
        @data[:labels].push(category[0])
        @data[:datasets][0][:data].push(category[1]/total_revenue)*100
      end
    end
  end

  attr_accessor :start_at, :end_at
end