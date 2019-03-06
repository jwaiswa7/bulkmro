class Overseers::PaymentCollectionEmailsController < Overseers::BaseController
  def new
    if params[:type].downcase == 'company'
      @company = Company.find(params[:company])

      @email_message = @company.email_messages.build(overseer: current_overseer, contact: @company.default_contact)
      @email_message.assign_attributes(
        subject: 'Company Payment Collection',
        body: CompanyPaymentCollectionMailer.acknowledgement(@email_message).body.raw_source,
        auto_attach:true
          )
    else
      params[:type].downcase
      @account = Account.find(params[:account])
      @email_message = @account.email_messages.build(overseer: current_overseer)
      @email_message.assign_attributes(
        subject: 'Account Payment Collection',
        body: AccountPaymentCollectionMailer.acknowledgement(@email_message).body.raw_source,
        auto_attach:true
          )
    end
    authorize :payment_collection_emails
  end

  def create
    authorize :payment_collection_emails
    if params.has_key?('company')
      @company = Company.find(params['company'])
      @company_email_message = @company.email_messages.build(overseer: current_overseer)
      email_variable_assign_attribute(@company_email_message, 'company', @company)
    elsif params.has_key?('account')
      @account = Account.find(params['account'])
      @account_email_message = @account.email_messages.build(overseer: current_overseer)
      email_variable_assign_attribute(@account_email_message, 'account', @account)
    end
  end

  def email_variable_assign_attribute(email_message_obj, type_of_mail, object)
    email_message_obj.assign_attributes(email_message_params)
    email_message_obj.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    email_message_obj.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    if email_message_obj.auto_attach?
      # email_message_obj.files.attach(io: File.open(RenderCsvToFile.for(object)), filename: @sales_quote.filename(include_extension: true))
      email_message_obj.files.attach(io: File.open(RenderCsvToFile.for(object)), filename: object.name + '-pending-payments.csv')
    end

    if email_message_obj.save
      if type_of_mail == 'company'
        CompanyPaymentCollectionMailer.send_acknowledgement(email_message_obj).deliver_now
        redirect_to payment_collection_overseers_account_companies_path(email_message_obj.company.account)
      elsif type_of_mail == 'account'
        AccountPaymentCollectionMailer.send_acknowledgement(email_message_obj).deliver_now
        redirect_to payment_collection_overseers_accounts_path
      end
    end
  end

  private

    def email_message_params
      params.require(:email_message).permit(
        :subject,
          :body,
          :to,
          :cc,
          :bcc,
          :auto_attach,
          files: []
      )
    end

  attr_accessor :company, :account
end
