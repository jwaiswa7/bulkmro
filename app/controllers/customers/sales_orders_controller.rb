class Customers::SalesOrdersController < Customers::BaseController

  def index
    account = current_contact.account
    @sales_orders = ApplyDatatableParams.to(account.sales_orders, params)
  end

end
