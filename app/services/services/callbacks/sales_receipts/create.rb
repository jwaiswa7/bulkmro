class Services::Callbacks::SalesReceipts::Create < Services::Callbacks::Shared::BaseCallback

  def call
    begin
      invoice = SalesInvoice.find_by_invoice_number(params['p_invoice_no'])
      company = Company.find_by_remote_uid!(params['cmp_id'])

      if invoice.present?
        SalesReceipt.where(:remote_reference => params['p_sap_reference_number']).first_or_create! do |sales_receipt|
          sales_receipt.assign_attributes(
              :sales_invoice => invoice,
              :company => company,
              :metadata => params.to_json
          )
        end
        return_response("Sales Receipt created successfully.")
      else
        return_response("Sales Invoice not found.", 0)
      end
    rescue => e
      return_response(e.message, 0)
    end
  end

  attr_accessor :params
end

