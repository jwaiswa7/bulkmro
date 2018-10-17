class Customers::SalesQuotesController < Customers::BaseController

  def index
    account = current_contact.account
    @sales_quotes = ApplyDatatableParams.to(account.sales_quotes, params)
  end

end
