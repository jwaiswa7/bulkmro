class Overseers::CreditNotesController < Overseers::BaseController
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
end
