

class Services::Callbacks::SalesReceipts::Create < Services::Callbacks::Shared::BaseCallback
  def call
    begin
      invoice = SalesInvoice.find_by_invoice_number(params['p_invoice_no'])
      company = Company.find_by_remote_uid!(params['cmp_id'])

      SalesReceipt.where(remote_reference: params['p_sap_reference_number']).first_or_create! do |sales_receipt|
        sales_receipt.assign_attributes(
          sales_invoice: invoice,
          company: company,
          metadata: params.to_json
        )
      end
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
