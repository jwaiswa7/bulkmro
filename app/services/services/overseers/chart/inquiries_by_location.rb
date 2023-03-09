class Services::Overseers::Chart::InquiriesByLocation
  def initialize
    @locations = ["location 0", "location 1", "location 2", "location 3", "location 4"]
    @values = [25,20,20,25,10]
  end

  def call 
    
    colors =  ["rgb(230, 25, 75)", "rgb(60, 180, 75)", "rgb(255, 225, 25)", "rgb(90, 115, 34)", "rgb(0, 130, 200)"]

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
    