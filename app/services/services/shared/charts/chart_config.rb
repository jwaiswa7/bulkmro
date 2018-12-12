class Services::Shared::Charts::ChartConfig < Services::Shared::BaseService
  def initialize
    super
  end

  def get_multi_axis_mixed_chart
    @chart = []
    @data = {
        labels: [],
        datasets: [{
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
                   }]
    }

    @options = {
        scales: {
            yAxes: [{
                        id: 'products_count',
                        type: 'linear',
                        position: 'right',
                    }, {
                        id: 'revenue',
                        type: 'linear',
                        position: 'left',
                        ticks:{
                            display:true,
                            userCallback: ''
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Revenue'
                        }
                    }]
        }
    }
  end
end