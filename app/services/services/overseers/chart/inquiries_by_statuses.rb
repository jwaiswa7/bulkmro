class Services::Overseers::Chart::InquiriesByStatuses
  def initialize
    @statuses = Inquiry.statuses.keys.first(10)
    @values = Inquiry.statuses.values.first(10)
  end

  def call 
    total = values.sum

    data_set = values.map { |val| ((val/total.to_f)*100).round(2)}
    
    colors =  ["rgb(230, 25, 75)", "rgb(60, 180, 75)", "rgb(255, 225, 25)", "rgb(90, 115, 34)", "rgb(0, 130, 200)", "rgb(245, 130, 48)", "rgb(145, 30, 180)", "rgb(70, 240, 240)", "rgb(240, 50, 230)", "rgb(210, 245, 60)", "rgb(250, 190, 212)", "rgb(0, 128, 128)", "rgb(220, 190, 255)", "rgb(170, 110, 40)", "rgb(255, 250, 200)", "rgb(128, 0, 0)","rgb(97, 68, 76)", "rgb(170, 255, 195)", "rgb(128, 128, 0)", "rgb(255, 215, 180)", "rgb(0, 0, 128)", "rgb(128, 128, 128)", "rgb(255, 255, 255)", "rgb(0, 0, 0)"]

    {
        labels: statuses,
        datasets: [{
          label: 'My First Dataset',
          data: data_set,
          backgroundColor: colors.first(10),
          hoverOffset: 4
        }]
      };
  end

  private 

  attr_accessor :statuses, :values
end
  