class SalesQuoteMailer < ApplicationMailer
  before_action { @inquiry = params[:inquiry], @quote = params[:quote], @customer= Contact.find(params[:inquiry][:contact_id])  }

  #after_action :set_delivery_options
  #
  default from:   -> { params[:overseer][:email] },
          to:     -> { @customer.email }
          # reply_to: -> { @inviter.email_address_with_name }
  def sales_quote_ack
    subject =  "Quote Request #" + @quote.id.to_s + " : {{var caption}}"
    # file = Rails.root + "app/assets/images/26159_Calc_Sheet.pdf"
    # attachments['salequote.jpg'] = File.open(file, 'rb'){|f| f.read}
    file = open('https://bulkmro.com/skin/frontend/base/default/images/Beta-logo.png').read
    attachments['salequote.jpg'] = file
    mail subject: subject
  end

  def sales_quote_sent
    subject =  "Quote Request #" + @quote.id.to_s + " : {{var caption}}"
    #attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    mail subject: subject
  end

end
