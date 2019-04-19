class Services::Shared::Migrations::ChangeStatusesInInvoice < Services::Shared::Migrations::Migrations
  def call
    cancelled_invoice_requests = InvoiceRequest.where(status: "Cancelled")

    cancelled_invoice_requests.each do |invoice_request|
      if invoice_request.grpo_number.present?
        invoice_request.status = 'Cancelled GRPO'
        invoice_request.grpo_cancellation_reason = 'Migrated data, no reason specified'
      else
        invoice_request.status = 'Cancelled AP Invoice'
        invoice_request.ap_cancellation_reason = 'Migrated data, no reason specified'
      end
      invoice_request.save!
    end
  end
end
