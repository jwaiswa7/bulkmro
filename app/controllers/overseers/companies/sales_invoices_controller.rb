# frozen_string_literal: true

class Overseers::Companies::SalesInvoicesController < Overseers::Companies::BaseController
  def index
    base_filter = {
        base_filter_key: 'company_id',
        base_filter_value: params[:company_id]
    }
    authorize @company
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

  def payment_collection
    service = Services::Overseers::SalesInvoices::PaymentDashboard.new(@company)
    service.call
    @summery_data = service.summery_data

    authorize :sales_invoice
    base_filter = {
        'base_filter_key': 'sales_order_id',
        'base_filter_value': @company.sales_orders.pluck(:id).uniq
    }

    respond_to do |format|
      format.html { }
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
        'base_filter_key': 'sales_order_id',
        'base_filter_value': @company.sales_orders.pluck(:id).uniq
    }

    respond_to do |format|
      format.html { }
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
end
