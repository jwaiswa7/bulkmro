class SalesQuoteMailer < ApplicationMailer
  before_action :set_records

  after_action :set_delivery_options


  default from: -> {@sender.email},
          to: -> {@recipient.email}
  # reply_to: -> { @inviter.email_address_with_name }

  def sales_quote_ack
    subject = "Quote Request (#{@quote.id}) => #{@inquiry.subject}"
    filename = 'salequote_' + @quote.id.to_s + '.png'
    # file = Rails.root + "app/assets/images/26159_Calc_Sheet.pdf"
    # attachments[filename] = File.open(file, 'rb'){|f| f.read}
    file = open('https://bulkmro.com/skin/frontend/base/default/images/Beta-logo.png').read
    attachments[filename] = file
    mail subject: subject
  end

  def sales_quote_sent
    subject = "Quote Request (#{@quote.id}) => #{@inquiry.subject}"
    #attachments['filename.jpg'] = File.open(file, 'rb'){|f| f.read}
    mail subject: subject
  end

  private

  def set_records
    @sender = Overseer.find(params[:overseer])
    @inquiry = params[:inquiry]
    @quote = params[:quote]
    @recipient = Contact.find(params[:inquiry][:contact_id])
  end

  def set_delivery_options
    @smtp = GmailSmtp.where(:email => @sender.email).first

    mail.delivery_method.settings[:user_name] = @smtp.email
    mail.delivery_method.settings[:password] = @smtp.password
  end
end
