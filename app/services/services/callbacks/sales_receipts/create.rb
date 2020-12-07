class Services::Callbacks::SalesReceipts::Create < Services::Callbacks::Shared::BaseCallback
  def call
    begin

      company = Company.find_by_remote_uid!(params['cmp_id'])
      currency = Currency.find_by_name(params['p_amount_currency'])
      account = company.present? ? company.account : nil
      amount_received = params['p_amount_received'].split(',').map(&:to_f).reduce(:+)
      payment_type = nil

      if amount_received.to_f == 0 && params['on_account'].to_f > 0 && params['reconciled_amount'].to_f == 0
        total_amount_received = params['on_account'].to_f
        payment_type = 'On Account'
      elsif amount_received.to_f == 0 && params['on_account'].to_f > 0 && params['reconciled_amount'].to_f > 0
        total_amount_received = params['on_account'].to_f
        payment_type = 'Reconciled Against Invoice'
      elsif amount_received.to_f > 0 && params['on_account'].to_f == 0 && params['reconciled_amount'].to_f == 0
        total_amount_received = amount_received.to_f
        payment_type = 'Against Invoice'
      elsif amount_received.to_f > 0 && params['on_account'].to_f > 0 && params['reconciled_amount'].to_f == 0
        total_amount_received = params['on_account'].to_f + amount_received.to_f
        payment_type = 'On Account and Against Invoice'
      elsif amount_received.to_f > 0 && params['on_account'].to_f > 0 && params['reconciled_amount'].to_f > 0
        total_amount_received = params['on_account'].to_f + amount_received.to_f
        payment_type = 'On Account and Against Invoice'
      else
        total_amount_received = 0.0
      end

      # validate reconciled amount if present
      is_valid = true
      if params['reconciled_amount'].to_f > 0
        if params['p_invoice_no'].present?
          reconciled_invoice_amount = 0.0
          params['p_invoice_no'].each do |si_payment|
            reconciled_invoice_amount += si_payment['amount_received'].to_f
          end
        end

        sr = SalesReceipt.find_by_remote_reference(params['p_sap_reference_number'])
        if sr.present?
          reconciled_invoice_amount = reconciled_invoice_amount - sr.rows.sum(:amount_received)
        end

        if params['reconciled_amount'].to_f == reconciled_invoice_amount.to_f
          is_valid = true
        else
          is_valid = false
        end
      end

      if is_valid
        sales_receipt = SalesReceipt.where(remote_reference: params['p_sap_reference_number']).first_or_create! do |sales_receipt_object|
          sales_receipt_object.assign_attributes(
            company: company,
            account: account,
            metadata: params,
            currency: currency,
            payment_type: payment_type, # have to change as per new data
            payment_received_date: params['p_received_date'],
            payment_amount_received: total_amount_received,
            reconciled_amount: params['reconciled_amount']
          )
        end

        if params['p_invoice_no'].present?
          invoices_hash = {}
          params['p_invoice_no'].split(',').each_with_index do |value, index|
            invoices_hash[value] = params['p_amount_received'].split(',')[index]
          end

          invoices_hash.each do |invoice_number, amount|
            sales_invoice = SalesInvoice.find_by_invoice_number(invoice_number)
            if sales_invoice.present?
              # create sales receipt rows
              sales_receipt.rows.where(sales_invoice: sales_invoice).first_or_create! do |sales_receipt_row|
                sales_receipt_row.assign_attributes(amount_received: amount)
              end

              # update sales invoice payment status
              receivable_amount = sales_invoice.calculated_total_with_tax
              received_amount = sales_invoice.sales_receipt_rows.sum(:amount_received)
              if received_amount == 0.0
                payment_status = 'Unpaid'
              elsif received_amount < receivable_amount
                payment_status = 'Partially Paid'
              elsif receivable_amount == received_amount
                payment_status = 'Fully Paid'
              end

              sales_invoice.update_attributes!(payment_status: payment_status)
            end
          end
        end
        return_response('Sales Receipt created successfully.')
      else
        return_response('Reconciled amount is present, but no invoices or invoice\'s received amount does not match reconciled amount.', 0)
      end
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
