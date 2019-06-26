# frozen_string_literal: true

class Overseers::Companies::SalesInvoicesController < Overseers::Companies::BaseController
  def index
    base_filter = {
        base_filter_key: 'company_id',
        base_filter_value: params[:company_id]
    }
    authorize_acl :sales_invoice
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
