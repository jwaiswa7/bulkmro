class Callbacks::SalesReceiptsController < Callbacks::BaseController

  def create
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''
    #request params: {"p_method":"TransferAcct","p_amount_received":"","p_received_date":"2018-04-03","p_invoice_no":"","p_sap_reference_number":"70200002","p_comments":"GEINDIAINDUSTRIALPRIVATELIMITEDThroughUTRNOHSBCN18093855265invno3000556","p_amount_currency":"INR","on_account":"163077.18","cmp_id":"1"}
    if params['p_invoice_no'] && params['p_method'] && params['p_amount_received'] && params['p_received_date'] && params['p_sap_reference_number']
      if params['down_payment'] && params['down_payment'] > 0
        if params['p_order_id'] && params['p_tally_reference_number']
          #insert into tabel down_payment_receipt => downpayment_method= p_method, downpayment_amount_received = down_payment, downpayment_received_date= p_received_date, downpayment_created_date = now(), downpayment_order_id = p_order_id,downpayment_currency = p_amount_currency, downpayment_tally_reference_number = p_sap_reference_number
          resp_status = 1
          resp_msg = "Down Payment Created Successfully"
        else
          resp_msg = "Order Id And enter sap reference no are required"
        end
      else
        ref_status = 0
        ref_error = ''
        #params['p_amount_received'] params['p_invoice_no'] comma separated line to array. Both values co-related by order
        invoiceArry = params['p_invoice_no'].split(/\s*,\s*/)
        amountArry = params['p_amount_received'].split(/\s*,\s*/)
        params['p_method'] = params['p_method'] == 'reconcile' ? 'free' : params['p_method']
        invoiceArry.each do |k, invoice|
          #validate invoice exist and valid at our end. If failed add respective error to ref_error and continue(iterate to next cycle)
          begin
            # Insert into payment_status P_id(pk), P_payment_id = increment_id, p_order_id = order_id, P_amount_received = amountArry[k], P_amount_left = 0, P_due_date = '', P_received_date = params['P_received_date'],  P_created_date = date('Y-m-d'), P_comments = params['P_comments'],  P_invoice_id = invoice,  P_reference_number = '',  P_followup_date = '',  P_amount_currency = params['P_amount_currency'], P_tally_reference_number = params['p_sap_reference_number']
            if params['p_method'] == 'free'
              amtOnaccount = -1 * abs(params['p_amount_received'])
              #INSERT INTO onaccountpayment_status oap_id(pk),oap_method = 'invoice',oap_amount_received = amtOnaccount,  ,oap_received_date = params['p_received_date'], oap_created_date = date('Y-m-d'), oap_comments = '', oap_company_id = params['cmpId'], oap_reference_number = invoice,oap_currency = params['p_amount_currency'],oap_tally_reference_number = params['p_tally_reference_number'])
            end
            ref_status = 1
          rescue => ex
            ref_error += invoice + " => " + ex.message + "/"
          end
        end
        if params['cmp_id'] && params['on_account']
          begin
            #INSERT INTO onaccountpayment_status (oap_id(pk),oap_method = params['p_method'], oap_amount_received = params['on_account'],oap_received_date = params['p_received_date'], oap_created_date = date('Y-m-d'), oap_comments = '', oap_company_id = params['cmp_id'], oap_reference_number = '', oap_currency = params['p_amount_currency'],oap_tally_reference_number = params['p_sap_reference_number']
            ref_status = 1
          rescue => ex
            ref_error += params['p_sap_reference_number'] + " => " + ex.message + "/"
          end
        end
        if ref_status
          resp_status = 1
          if !ref_error.empty?
            resp_msg = "Receipt Created with some errors: " + ref_error
          else
            resp_msg = "Receipt Created Successfully"
          end
        else
          resp_status = 0
          resp_msg = "Receipt Creation failed"
        end
      end
    end
    response = format_response(resp_status, resp_msg)
    render json: response, status: :ok
  end
end