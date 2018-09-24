class SalesQuoteMailer < ApplicationMailer
  before_action { @inquiry = params[:inquiry], @quote = params[:quote], @customer= Contact.find(params[:inquiry][:contact_id])  }

  #after_action :set_delivery_options
  #
  default from:   -> { params[:overseer][:email] },
          to:     -> { @customer.email }
          # reply_to: -> { @inviter.email_address_with_name }
  def sales_quote_ack
    subject =  "Quote Request #" + @quote.id.to_s + " : {{var caption}}"
    file = Rails.root + "app/assets/images/26159_Calc_Sheet.pdf"
    attachments['salequote.pdf'] = File.open(file, 'rb'){|f| f.read}
    mail subject: subject
  end

  def sales_quote_sent
    subject =  "Quote Request #" + @quote.id.to_s + " : {{var caption}}"
    #attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    mail subject: subject
  end

end
