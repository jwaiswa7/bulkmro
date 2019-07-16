class Overseers::BibleInvoicesController < Overseers::BaseController
  before_action :set_bible_invoice, only: [:show]

  def index
    @sales_invoices = ApplyDatatableParams.to(BibleInvoice.all, params)
    authorize_acl :bible_invoice, 'index'
  end

  def show
    authorize_acl :bible_invoice, 'show'

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice
      end
    end
  end

  private

  def set_bible_invoice
    @sales_invoice = BibleInvoice.find(params[:id])
  end

end