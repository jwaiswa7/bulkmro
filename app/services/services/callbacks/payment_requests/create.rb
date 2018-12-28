class Services::Callbacks::PaymentRequests::Create < Services::Callbacks::Shared::BaseCallback

  def call
    po_request = params[:po_request]
    purchase_order = po_request.purchase_order
    inquiry = po_request.inquiry
    begin
      if purchase_order.present?
        if purchase_order.payment_request.nil?
          payment_request = PaymentRequest.new
          payment_request.update_attributes(:purchase_order => purchase_order, :inquiry => inquiry, :po_request => po_request)
          return_response("Payment Request created successfully.")
          puts "Payment Request created successfully."
        else
          return_response("Payment Request is already created.")
          puts "Payment Request is already created."
        end
      else
        return_response("Purchase order not found.", 0)
      end
    rescue => e
      return_response(e.message, 0)
    end
  end

  attr_accessor :params
end
