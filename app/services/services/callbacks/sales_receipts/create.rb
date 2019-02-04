class Services::Callbacks::SalesReceipts::Create < Services::Callbacks::Shared::BaseCallback

  def call
    begin
      invoice = SalesInvoice.find_by_invoice_number(params['p_invoice_no'])
      company = Company.find_by_remote_uid!(params['cmp_id'])
      currency = Currency.find_by_remote_uid!(params['p_amount_currency'])

      SalesReceipt.where(:remote_reference => params['p_sap_reference_number']).first_or_create! do |sales_receipt|
        sales_receipt.assign_attributes(
            :sales_invoice => invoice,
            :company => company,
            :metadata => params.to_json,
            :currency => currency,
            :payment_type => (params['on_account'] == "1" ? 10 : (params['on_account'] == "0" ? 20 : nil) ),
            :payment_received_date => params['p_received_date'],
            :payment_amount_received => params['p_amount_received']

        )
      end
      return_response("Sales Receipt created successfully.")
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

