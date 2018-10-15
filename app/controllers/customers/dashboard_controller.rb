class Customers::DashboardController < Customers::BaseController

  def show
    @contact = current_contact
    @inquiries_count = @contact.inquiries.count

  end

end