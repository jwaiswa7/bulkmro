class Services::Callbacks::SalesReceipts::Create < Services::Callbacks::Shared::BaseCallback
  def call
    begin
      invoice = SalesInvoice.find_by_invoice_number(params['p_invoice_no'])
      company = Company.find_by_remote_uid!(params['cmp_id'])
      currency = Currency.find_by_name(params['p_amount_currency'])
      account = company.present? ? company.account.id : nil
      payment_type = nil
      if params['cmp_id'].present? && !params['p_invoice_no'].present?
        amount_recived = params[:on_account]
        payment_type = 'On Account'
      elsif params['p_invoice_no'].present?
        amount_recived = params[:p_amount_received]
        payment_type = 'Against Invoice'
      else
        amount_recived = 0.0
      end
      SalesReceipt.where(remote_reference: params['p_sap_reference_number']).first_or_create! do |sales_receipt|
        sales_receipt.assign_attributes(
          sales_invoice: invoice,
          company: company,
          account: account,
          metadata: params,
          currency: currency,
          payment_type: payment_type, # have to change as per new data
          payment_received_date: params['p_received_date'],
          payment_amount_received: amount_recived

        )
      end
      if invoice.present?
        receivable_amount = invoice.calculated_total_with_tax
        received_amount = invoice.sales_receipts.sum(:payment_amount_received)
        if received_amount == 0.0
          payment_status = 'Unpaid'
        elsif received_amount < receivable_amount
          payment_status = 'Partially Paid'
        elsif receivable_amount == received_amount
          payment_status = 'Fully Paid'
        end
      end
      invoice.update__attributes(payment_status: payment_status)
      return_response('Sales Receipt created successfully.')
    rescue => e
      return_response(e.message, 0)
    end
  end

  attr_accessor :params
end

# {
#     "p_method":"TransferAcct",
#     "p_amount_received":"",
#     "p_received_date":"2018-04-03",
#     "p_invoice_no":"",
#     "p_sap_reference_number":"70200002",
#     "p_comments":"GEINDIAINDUSTRIALPRIVATELIMITEDThroughUTRNOHSBCN18093855265invno3000556",
#     "p_amount_currency":"INR",
#     "on_account":"163077.18",
#     "cmp_id":"1"
# }
