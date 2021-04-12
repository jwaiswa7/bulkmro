class Services::Callbacks::CreditNotes::Create < Services::Callbacks::Shared::BaseCallback
  def call
    sales_invoice = SalesInvoice.find_by_invoice_number(params['invoice_number'])
    credit_note_precense = CreditNote.find_by(memo_number: params['memo_number'])
    method = credit_note_precense.present? ? :patch : :post
    @callback_request = CallbackRequest.where(resource: 'CreditNote', method: method, subject_id: params['memo_number']).first_or_create do |cr|
      cr.update(
        url: '/CreditNote',
        status: :pending,
        subject_type: CreditNote
      )
    end
    if sales_invoice.present?
      credit_note = sales_invoice.credit_notes.where(memo_number: params['memo_number']).first || sales_invoice.credit_notes.build(memo_number: params['memo_number'], memo_date: params['memo_date'].to_date, memo_amount: params['memo_amount'], metadata: params['metadata'])
      if credit_note.persisted?
        credit_note.update_attributes!(memo_date: params['memo_date'].to_date, memo_amount: params['memo_amount'], metadata: params['metadata'])
        @callback_request.update_attributes(request: credit_note.to_json)
        return_response('AR Credit Note updated successfully.', 1)
      else
        credit_note.save!
        @callback_request.update_attributes(request: credit_note.to_json)
        return_response('AR Credit Note created successfully.', 1)
      end
      status = sales_invoice.rows.count == credit_note.metadata['lineItems'].count ? 209 : 208
      sales_invoice.update_attributes(status: status)
    else
      credit_note = CreditNote.find_or_create_by(memo_number: params['memo_number'])
      credit_note.update_attributes(memo_date: params['memo_date'].to_date, memo_amount: params['memo_amount'], metadata: params['metadata'])
      return_response('CrediNote created without sales invoice.', 1)
    end
  rescue => e
    return_response(e.message, 0)
  end

  attr_accessor :params
end
