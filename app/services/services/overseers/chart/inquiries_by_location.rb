class Services::Overseers::Chart::InquiriesByLocation
  def initialize
    @locations = %w[Mumbai
      Ahmedabad
      Delhi
      Hyderabad
      Pune
      Vadodara]
    @values = locations.map{|location| rand(10..100) }
  end

  def call 
    
    colors =  ["rgba(137,219,253,255)", "rgba(176,122,106,255)", "rgba(247,218,209,255)", "rgba(32,138,179,255)", "rgb(194,186,188)", "rgba(112,126,126,255)"]

    {
        labels: locations,
        datasets: [{
          label: 'My First Dataset',
          data: values,
          backgroundColor: colors,
          hoverOffset: 4
        }]
      };
  end

  private 

  attr_accessor :locations, :values
end