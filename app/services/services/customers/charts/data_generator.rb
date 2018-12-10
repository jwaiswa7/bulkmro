class Services::Customers::Charts::DataGenerator < Services::Shared::BaseService

  def initialize(product_ids, quantities , date_start, date_end)
    @product_ids = product_ids
    @quantities = quantities
    @date_start = date_start
    @date_end = date_end
  end

  def chart_data(x_axis_data, y_axis_data, legend_names)
    @data = {
        labels: ["January", "February", "March", "April", "May", "June", "July"],
        datasets: [{
                       label: ["Europe"],
                       type: "bar",
                       borderColor: "#8e5ea2",
                       data: [temp[1].calculated_total, temp[5].calculated_total, temp[7].calculated_total, temp[1].calculated_total],
                       fill: false,
                       yAxisID: 'A'
                   },
                   {
                       label: "Europe",
                       type: "line",
                       backgroundColor: "#fd7e14",
                       data: [p, p + 7, p + 8, p + 2],
                       yAxisID: 'B',
                       fill: false
                   }]
    }
    @options = {
        scales: {
            yAxes: [{
                        id: 'A',
                        type: 'linear',
                        position: 'left',
                    }, {
                        id: 'B',
                        type: 'linear',
                        position: 'right',

                    }]
        }
    }


    # data  = { labels: x_axis_data, datasets: [] }
    #
    # y_axis_data.each_with_index do |level, i|
    #   data[:datasets] << {
    #       label: legend_names,
    #       fill: false,
    #       borderColor: '#50BB70',
    #       pointBorderColor: '#47A7D4',
    #       data: level,
    #       backgroundColor: '#50BB70'
    #   }
    end

    data
  end

  attr_accessor :product_ids, :quantities, :date_start, :date_end
end