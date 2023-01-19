class Services::Overseers::Products::Importer < Services::Shared::BaseService
  # this class is used to carry out he product import process after a product import record has been created
  # Products will be imported based on the uploaded product import file
  # Once complete, then an email will be sent to the overseer that created the product import

  class ExcelInvalidHeader < StandardError; end

  class ExcelInvalidRows < StandardError; end

  # Initializes the class with a product import id
  #
  #  == params
  #  [product_import_id]
  #    id of the product import being processed
  #
  def initialize(product_import_id)
    @product_import = ProductImport.find(product_import_id)
    @rows = []
    @failed_imports = []
  end

  # Calls the differen methods of the class performing the product import process
  def call
    set_and_validate_excel_rows
    set_and_validate_excel_header_row
    set_rows
    import_products
    send_email
    ProductsIndex.import # Import created products into the product index
  end

  private

    # Creates an email message recrod and sends an email to the product import overseer
    # this function will attach to the email the product import report as a csv file
    def send_email
      email_message = product_import.email_messages.new(
        subject: 'Bulk Product notification',
        from: 'itops@bulkmro.com',
        to: product_import.overseer.email
      )
      email_message.assign_attributes(
        body: ProductImportMailer.import_notification(email_message, product_import.overseer).body.raw_source,
      )

      email_message.files.attach(
        io: StringIO.new(generate_error_report),
        filename: 'error_report.csv',
        content_type: 'text/csv'
      )

      if email_message.save
        ProductImportMailer.send_import_notification(email_message).deliver_now
      end
    end

    # Generates the error report based on the errored product imports
    # The report is a csv file with the headers sr_no, name, date and errors
    def generate_error_report
      attributes = %w{sr_no, name, date, errors}
      CSV.generate(headers: true) do |csv|
        csv << attributes
        failed_imports.each do |error|
          csv << error
        end
      end
    end

    # This function approves a product
    #
    # === params
    #
    #  [product]
    #    this is the product object to be approved
    #
    # The function will create a comment with a default message and attach it the the approval on the product.
    #
    def approve_product(product)
      # system_admin 
      sys_admin = Overseer.find_by(email: "sysadmin@bulkmro.com") # assuming the application has a system user of email sysadmin@bulkmro.com
      comment = product.create_last_comment(message: 'System automatic approval after bulk upload', created_by: sys_admin)
      product.create_approval(comment: comment, created_by: sys_admin)
    end

    # This function creates products based on the product file rows.
    # If a product is created successfully, then it's saved
    # if a product hasn't been created successfully, then it's error is recorded in the failed imports array
    def import_products
      rows.each do |row|
        serial_number = row['sr_no']
        row.shift
        product = Product.new(row)
        product.is_bulk_upload = true
        if product.save_and_sync
          approve_product(product)
        else
          @failed_imports.push [serial_number, product.name, Date.today.to_s, product.errors.full_messages.join(',')]
        end
      end
    end

    # this function sets and validates the excel rows in the attached product import file
    def set_and_validate_excel_rows
      excel = SimpleXlsxReader.open(TempfilePath.for(product_import.file))
      excel_rows = excel.sheets.first.rows
      excel_rows.reject! { |er| er.compact.blank? }

      @excel_rows = excel_rows
    end

    # This sets and validates the excel row header
    def set_and_validate_excel_header_row
      @excel_header_row = excel_rows.shift


      excel_header_row.each do |column|
        if /^[a-zA-Z_]{1}[_a-zA-Z]*$/i.match?(column) && column.downcase.in?(ProductImport::TEMPLATE_HEADERS)
          column.downcase!
        else
          error = ["Invalid excel upload; the columns should be \n", ProductImport::TEMPLATE_HEADERS.to_sentence + '.'].join(' ')
          raise ExcelInvalidHeader, error
        end
      end
    end

    # this function will add the product rows to the rows array
    def set_rows
      excel_rows.each do |excel_row|
        row = excel_header_row.zip(excel_row).to_h
        row['measurement_unit'] = MeasurementUnit.find_by(name: row['measurement_unit']) # get the measurement unit id
        row['brand'] = Brand.find_by(name: row['brand']) # set the brand
        row['tax_code'] = TaxCode.find_by(code: row['tax_code']) # set the tax code
        row['tax_rate'] = TaxRate.find_by(tax_percentage: row['tax_rate']) # set the tax rate
        row['created_by'] = product_import.overseer

        rows.push row
      end
      @rows = rows
    end


    attr_accessor :product_import, :import, :excel_rows, :excel_header_row, :excel_products, :rows, :failed_imports
end
