class Services::Overseers::CreditNotes::Show < Services::Shared::BaseService
  def initialize(credit_note)
    @credit_note = credit_note
  end

  def call
    if credit_note.sales_invoice.inquiry.is_sez? || credit_note.sales_invoice.serialized_billing_address.country_code != 'IN'
      if credit_note.sales_invoice.metadata['created_at'].present? && Settings.accounts.try("arn_date_#{year}").present? && Date.parse(Settings.accounts.try("arn_date_#{year}")) <= Date.parse(credit_note.sales_invoice.metadata['created_at'])
        @arn_date = Date.parse(Settings.accounts.try("arn_date_#{year}"))
        @arn_number = Settings.accounts.try("arn_number_#{year}")
      else
        @arn_date = Date.parse(Settings.accounts.try('arn_date_2018'))
        @arn_number = Settings.accounts.try('arn_number_2018')
      end
    end
    @bill_from_warehouse = credit_note.sales_invoice.get_bill_from_warehouse
  end

  attr_accessor :credit_note, :bill_from_warehouse, :arn_number, :arn_date
end
