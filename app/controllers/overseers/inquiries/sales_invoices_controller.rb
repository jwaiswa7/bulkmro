class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show, :triplicate, :duplicate, :make_zip]

  def index
    @sales_invoices = @inquiry.invoices
    authorize @sales_invoices
  end

  def show
    authorize @sales_invoice
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice
      end
    end
  end

  def duplicate
    authorize @sales_invoice, :show?
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice, {duplicate: true}
      end
    end
  end

  def triplicate
    authorize @sales_invoice, :show?
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice, {triplicate: true}
      end
    end
  end

  def make_zip
    authorize @sales_invoice, :show?


    temp_invoice_file = Tempfile.new('temp_invoice.pdf')
    temp_invoice_file.puts(File.open(RenderPdfToFile.for(@sales_invoice)))
    temp_invoice_file.close

    temp_zip_file = 'tmp/archive.zip'

    Zip::File.open(temp_zip_file, Zip::File::CREATE) do |zip_file|
      zip_file.add(temp_invoice_file, temp_invoice_file.path)
    end

    zip_data = File.read(temp_zip_file)
    send_data(zip_data, :type => 'application/zip', :filename => "tf")
  end

  private

  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

end