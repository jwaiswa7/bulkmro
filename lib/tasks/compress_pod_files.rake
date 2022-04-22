include Rails.application.routes.url_helpers
require 'zip'
namespace :pod_files do

  task zip: :environment do
    start_date = Date.parse("2022-02-15")
    end_date = Date.parse("2022-04-21")
    archive_directory_path = Rails.root.join('public', 'pod_files')
    archive_zip_path = Rails.root.join('public', 'pod_files.zip')

    SalesInvoice.where(created_at: start_date..end_date).each do |sales_invoice|
      sales_invoice.pod_rows.each do |pod|
        pod.attachments.each do |attachment|
            IO.copy_stream(URI.open(url_for(attachment)),"#{archive_directory_path}/#{sales_invoice.invoice_number}-#{attachment.filename}")
        end if pod.attachments.attached?
      end
    end

    Zip::OutputStream.open(archive_zip_path) { |os| }
    Zip::File.open(archive_zip_path, Zip::File::CREATE) do |zip_file|
      Dir[ File.join( archive_directory_path, "**", "**" ) ].each do |file|
        zip_file.add( file.sub( "#{ archive_directory_path }/", "" ), file )
      end
    end

    # File.read( archive_zip_path )

  end
end
