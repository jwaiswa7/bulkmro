# frozen_string_literal: true

class Services::Callbacks::SalesInvoices::Update < Services::Callbacks::Shared::BaseCallback
  def call
    begin
      sales_invoice = SalesInvoice.find_by_invoice_number(params['increment_id'])
      remote_coment = params['comment']
      remote_status = params['state'].to_i
      comment_message = [
          ["Invoice ##{params['increment_id']} Updated", SalesInvoice.statuses.key(remote_status)].join(': '),
          ['Comment', remote_coment].join(': '),
      ].join(' | ')

      if sales_invoice.present? && sales_invoice.sales_order.present?
        if params['state'].present?
          sales_invoice.update_attributes(status: params['state'].to_i)

          if params['state'].to_i == 3
            invoice_request = InvoiceRequest.find_by_ar_invoice_number(params[:increment_id])
            if invoice_request.present?
              invoice_request.update_attributes!(status: ' Cancelled AR Invoice')
            end
          end
        end
        sales_invoice.sales_order.inquiry.comments.create!(message: comment_message, overseer: Overseer.default_approver)

        return_response('Sales Invoice updated successfully.')
      else
        return_response('Sales Invoice or Sales Order for this invoice not found.', 0)
      end
    rescue => e
      return_response(e.message, 0)
    end
  end

  def to_local_status(remote_status)
    case remote_status
    when '1'
      :'Approved'
    when '2'
      :'SAP Rejected'
    when '3'
      :'SAP Rejected'
    end
  end

  attr_accessor :params
end

# {
#     "increment_id":"20610329",
#     "state":"206",
#     "comment":"BasedOnSalesQuotations1731.BasedOnSalesOrders10610269.BasedOnDeliveries30610471."
# }
