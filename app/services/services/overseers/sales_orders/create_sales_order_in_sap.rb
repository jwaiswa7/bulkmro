class Services::Overseers::SalesOrders::CreateSalesOrderInSap < Services::Shared::BaseService
  def initialize(sales_order, params, notification)
    @sales_order = sales_order
    @params = params
    @overseer = params[:overseer]
    @notification = notification
  end

  def call
    if params['approve'].present?
      date = Date.today
      year = date.year
      year = year - 1 if date.month < 4
      series_name = sales_order.sales_quote.bill_from.series_code + ' ' + year.to_s
      series = Series.where(document_type: 'Sales Order', series_name: series_name)
      if series.present? && sales_order.status != 'Approved'
        sales_order.update_attributes(remote_status: :'Supplier PO: Request Pending', status: :'Approved', mis_date: Date.today, order_number: series.first.last_number)
        series.first.increment_last_number
        doc_id = ::Resources::Order.create(sales_order)
        order = ::Resources::Order.find(doc_id)
        if order.present?
          sales_order.update_attributes(remote_uid: order['DocEntry'])
          company = sales_order.company
          company_so_amount = company.company_transactions_amounts.where(financial_year: Company.current_financial_year).last
          company_so_amount.increment_total_amount(sales_order.calculated_total_with_tax) if company_so_amount.present?
        end
        Services::Overseers::Inquiries::UpdateStatus.new(sales_order, :order_won).call
        comment = sales_order.inquiry.comments.create!(message: 'SAP Approved', overseer: overseer, sales_order: sales_order)
        if sales_order.approval.blank?
          sales_order.create_approval!(comment: comment, overseer: overseer)
          sales_order.rejection.destroy! if sales_order.rejection.present?
        end
        # trigger notification to sales manager and sales executives
        @notification.send_so_approved_by_account(
          sales_order,
            params[:action],
            sales_order,
            Rails.application.routes.url_helpers.overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order),
            'approved'
        )
        # sales_order.serialized_pdf.attach(io: File.open(RenderPdfToFile.for(sales_order)), filename: sales_order.filename)
        sales_order.update_index
      end
    else
      sales_order.update_attributes(status: :'SAP Rejected')
      reason = if params[:sales_order][:custom_fields][:reject_reasons].present? && params[:sales_order][:custom_fields][:message].present?
        params[:sales_order][:custom_fields][:reject_reasons].reject(&:empty?).join(', ') + ' - ' + params[:sales_order][:custom_fields][:message]
      else
        params[:sales_order][:custom_fields][:reject_reasons].reject(&:empty?).join(', ')
      end
      comment = InquiryComment.where(message: "Rejected by Accounts. Reason(s): #{reason}",
                                     inquiry: sales_order.inquiry, created_by: overseer, updated_by: overseer,
                                     sales_order: sales_order).first_or_create! if sales_order.inquiry.present?
      Services::Overseers::Inquiries::UpdateStatus.new(sales_order, :sap_rejected).call
      sales_order.create_rejection!(comment: comment, overseer: overseer)
      sales_order.approval.destroy! if sales_order.approval.present?
      sales_order.update_index
      # trigger notification to sales manager and sales executives
      @notification.send_so_approved_by_account(
        sales_order,
          params[:action],
          sales_order,
          Rails.application.routes.url_helpers.overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order),
          'rejected'
      )
    end
  end
  attr_accessor :sales_order, :params, :overseer
end
