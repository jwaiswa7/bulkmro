class Services::Customers::Charts::DataGenerator < Services::Shared::BaseService

  def initialize(product_ids, quantities , date_start, date_end)
    @product_ids = product_ids
    @quantities = quantities
    @date_start = date_start
    @date_end = date_end
  end

  def call
    chart_data(product_ids, quantities, legend_names="Product")
  end

  def chart_data(x_axis_data, y_axis_data, legend_names)
    data  = { labels: x_axis_data, datasets: [] }

    y_axis_data.each_with_index do |level, i|
      data[:datasets] << {
          label: legend_names,
          fill: false,
          borderColor: '#50BB70',
          pointBorderColor: '#47A7D4',
          data: level,
          backgroundColor: '#50BB70'
      }
    end

    data
  end

  attr_accessor :product_ids, :quantities, :date_start, :date_end
end