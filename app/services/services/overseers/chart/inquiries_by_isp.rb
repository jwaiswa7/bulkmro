class Services::Overseers::Chart::InquiriesByIsp

  def initialize 
    @labels = Overseer.first(29).map(&:name)
  end
  

  def call 
    {
      data: data, 
      options: options
    }
  end

  private 
  attr_accessor :labels 

  def data_set 
    labels.map{|label| rand(10..100)}
  end

  def first_colors 
    labels.map {|label| 'rgba(137,219,253,255)'}
  end

  def second_colors 
    labels.map {|label| 'rgba(176,122,106,255)'}
  end

  def data 
    {
      labels: labels,
      datasets: [{
        axis: 'y',
        label: 'My First Dataset',
        data: data_set,
        fill: false,
        backgroundColor: first_colors,
      },
      {
        axis: 'y',
        label: 'My second Dataset',
        data:  data_set,
        fill: false,
        backgroundColor: second_colors,
      }]
    };
  end

  def options 
    {
      height: 700,
      scales: {
        xAxes: [{
            stacked: true
        }],
        yAxes: [{
            stacked: true
        }]
    }
    }
  end
end
      