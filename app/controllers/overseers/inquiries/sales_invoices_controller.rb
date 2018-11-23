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
    # service = Services::Overseers::Inquiries::ZipEntries.new(@sales_invoice)
    # service.call

    input_filenames = []
    pdf_content = []
    folder = Rails.root.join('tmp')

    # temp file paths
    file_paths = [
        RenderPdfToFile.for(@sales_invoice),
        RenderPdfToFile.for(@sales_invoice,{duplicate: true}),
        RenderPdfToFile.for(@sales_invoice,{triplicate: true})
    ]

    # temp file names
    file_paths.each do |file_path|
      input_filenames.push(File.basename(file_path))
    end

    temp_zip_file = 'tmp/archive.zip'
    # Zip::OutputStream.open(temp_zip_file) { |zos| }

    # pdf string for each temp invoice file
    file_paths.each do |file_path|
      pdf_content.push(File.open(File.open(file_path)))
    end

    # updates zip
    Zip::File.open(temp_zip_file, Zip::File::CREATE) do |zip_file|
      input_filenames.each_with_index do |filename, index|

        # temp invoice creation
        temp_invoice_file = Tempfile.new()
        temp_invoice_file.puts(pdf_content[index])
        temp_invoice_file.close

        # adds file
        zip_file.add(filename, File.join(folder,filename))
      end
    end

    zip_data = File.read(temp_zip_file)
    send_data(zip_data, :type => 'application/zip', :filename => "Invoice - " + @sales_invoice.invoice_number.to_s)
    FileUtils.rm_rf(Dir.glob(Rails.root.join('tmp/archive.zip')))
  end

  private

  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

end