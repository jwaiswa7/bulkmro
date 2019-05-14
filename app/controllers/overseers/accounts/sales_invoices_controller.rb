class Overseers::Accounts::SalesInvoicesController < Overseers::Accounts::BaseController
  def show
    authorize_acl @account
  end

  def index
    base_filter = {
        base_filter_key: 'account_id',
        base_filter_value: params[:account_id]
    }
    authorize_acl @account
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records
      end
    end
  end
end
