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
    service = Services::Overseers::CreditNotes::Show.new(@credit_note)
    service.call
    @arn_date = service.arn_date
    @arn_number = service.arn_number
    @bill_from_warehouse = service.bill_from_warehouse
    
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
