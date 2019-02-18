class Overseers::Companies::SalesInvoicesController < Overseers::Companies::BaseController
  def index
    @sales_invoices = ApplyDatatableParams.to(@company.invoices, params.reject! { |k, v| k == 'company_id' })
    authorize @sales_invoices
  end

  def payment_collection
    service = Services::Overseers::SalesInvoices::PaymentDashboard.new(@company)
    service.call
    @summery_data = service.summery_data

    authorize :sales_invoice
    base_filter = {
        :base_filter_key => "sales_order_id",
        :base_filter_value => @company.sales_orders.pluck(:id).uniq
    }

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records.try(:reverse)

        service = Services::Overseers::SalesInvoices::PaymentDashboard.new(@company)
        service.call
        @summery_data = service.summery_data
      end
    end
  end

  def ageing_report
    service = Services::Overseers::SalesInvoices::AgeingReport.new(@company)
    service.call
    @summery_data = service.summery_data

    authorize :sales_invoice
    base_filter = {
        :base_filter_key => "sales_order_id",
        :base_filter_value => @company.sales_orders.pluck(:id).uniq
    }

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records.try(:reverse)

        service = Services::Overseers::SalesInvoices::PaymentDashboard.new(@company)
        service.call
        @summery_data = service.summery_data
        render 'payment_collection'
      end
    end
  end
end
