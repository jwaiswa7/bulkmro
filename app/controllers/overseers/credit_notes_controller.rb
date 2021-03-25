class Overseers::CreditNotesController < Overseers::BaseController
  before_action :set_credit_note, only: :show

  def index
    authorize_acl :credit_note
    service = Services::Overseers::Finders::CreditNotes.new(params, current_overseer)
    service.call
    @indexed_credit_notes = service.indexed_records
    @credit_notes = service.records
  end

  def resync_credit_note_from_sap
    authorize_acl :credit_note

    Resources::CreditNote.create_from_sap
    redirect_to overseers_credit_notes_path
  end

  def show
    if @credit_note.sales_invoice.inquiry.is_sez? || @credit_note.sales_invoice.serialized_billing_address.country_code != 'IN'
      if @credit_note.sales_invoice.metadata['created_at'].present? && Settings.accounts.try("arn_date_#{year}").present? && Date.parse(Settings.accounts.try("arn_date_#{year}")) <= Date.parse(@credit_note.sales_invoice.metadata['created_at'])
        @arn_date = Date.parse(Settings.accounts.try("arn_date_#{year}"))
        @arn_number = Settings.accounts.try("arn_number_#{year}")
      else
        @arn_date = Date.parse(Settings.accounts.try('arn_date_2018'))
        @arn_number = Settings.accounts.try('arn_number_2018')
      end
    end
    @bill_from_warehouse = @credit_note.sales_invoice.get_bill_from_warehouse
    respond_to do |format|
      format.pdf do
        render_pdf_for @credit_note, pagination: false
      end
    end
  end

  private

    def set_credit_note
      @credit_note = CreditNote.find(params[:id])
    end
end
