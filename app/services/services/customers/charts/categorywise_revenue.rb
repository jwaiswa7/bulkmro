

class Services::Customers::Charts::CategorywiseRevenue < Services::Customers::Charts::Builder
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
                  backgroundColor: ["#3e95cd", "#8e5ea2", "#3cba9f", "#e8c3b9", "#c45850", "#fd7e14"],
                  data: [],
              }
          ]
      }

      @options = {

      }

      sales_orders = SalesOrder.remote_approved.where(created_at: start_at..end_at).includes(:rows).joins(:company).where(companies: { id: company.id }).includes(:products, :categories)
      total_revenue = 0
      categorywise_revenue = {}

      sales_orders.each do |so|
        so.rows.each do |row|
          category = row.product.category.name
          if row.product.category.ancestors.present?
            categories = row.product.category.ancestors.pluck(:name) - Category.default_ancestors
            if categories.any?
              category = categories.last
            end
          end
          categorywise_revenue[category] ||= 0
          categorywise_revenue[category] = categorywise_revenue[category] + row.total_selling_price
          total_revenue += row.total_selling_price
        end
      end

      categorywise_revenue.each do |category|
        @data[:labels].push(category[0])
        @data[:datasets][0][:data].push(category[1] / total_revenue) * 100
      end
    end
  end

  attr_accessor :start_at, :end_at
end
