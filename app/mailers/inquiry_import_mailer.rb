class InquiryImportMailer < ApplicationMailer
    default template_path: "mailers/#{self.name.underscore}"
  
    
    def rfq_import_created_email(email_message, rfq_import)
        @inquiry = email_message.inquiry
        @rfq_import = rfq_import
        standard_email(email_message)
      end
    
      def send_rfq_import_created_email(email_message)
        @inquiry = email_message.inquiry
        email = htmlized_email(email_message)
        email.delivery_method.settings = Settings.sendgrid_smtp.to_hash
      end
    
  end
  