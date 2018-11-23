class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  require 'zip/zip'
  # include Zip
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
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    tf = Tempfile.new('archive.zip')

    temp_file = Tempfile.new('invoice')
    temp_file.puts File.open(RenderPdfToFile.for(@sales_invoice))
    temp_file.close
    # Zip < Zip
    Zip::ZipFile.open(tf, Zip::ZipFile::CREATE) do |z|
      z.add(temp_file, temp_file.path)
    end

    #Read the binary data from the file
    zip_data = File.read(tf.path)

    send_data(zip_data, :type => 'application/zip', :filename => "tf")

    tf.close
    tf.unlink
  end

  private

  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

end