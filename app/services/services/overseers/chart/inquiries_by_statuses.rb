class Services::Overseers::Chart::InquiriesByStatuses
  def initialize
    @statuses = ["Order Won", "Quotation Sent", "Order Lost", "Acknowledgement Mail", "New Inquiry", "Regret Request", "Cross Reference", "Preparing Quotation", "SO Draft: Pending", "Rejected by Accounts", "Expected Order"]
    @values =  [34, 48, 31, 35, 50, 31, 23, 35, 20, 44, 25]
  end

  def call 
    
    colors =  ["rgba(137,219,253,255)", "rgba(176,122,106,255)", "rgba(247,218,209,255)", "rgba(32,138,179,255)", "rgb(194,186,188)", "rgba(112,126,126,255)", "rgba(24,93,121,255)", "rgba(224,68,167,255)", "rgba(82,78,71,255)", "rgba(86,7,13,255)", "rgba(54,126,111,255)"]

    {
        labels: statuses,
        datasets: [{
          label: 'My First Dataset',
          data: values,
          backgroundColor: colors,
          hoverOffset: 4
        }]
      };
  end

  private 

  attr_accessor :statuses, :values
end
  