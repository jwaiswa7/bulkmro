class Services::Callbacks::CreditNotes::Create < Services::Callbacks::Shared::BaseCallback
  def call
    sales_invoice = SalesInvoice.find_by_invoice_number(params['invoice_number'])

    if sales_invoice.present?
      credit_note = sales_invoice.credit_note || sales_invoice.build_credit_note(memo_number: params['memo_number'], memo_date: params['memo_date'].to_date, memo_amount: params['memo_amount'], metadata: params['metadata'])
      if credit_note.persisted?
        credit_note.update_attributes!(memo_date: params['memo_date'].to_date, memo_amount: params['memo_amount'], metadata: params['metadata'])
        return_response('AR Credit Note updated successfully.')
      else
        credit_note.save!
        return_response('AR Credit Note created successfully.')
      end
      sales_invoice.update_attributes(status: 'Credit Note Issued')
    else
      return_response('AR Sales Invoice not present.', 0)
    end
  rescue => e
    return_response(e.message, 0)
  end

  attr_accessor :params
end
