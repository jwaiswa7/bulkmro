class Services::Shared::Migrations::ExportFilesDump < Services::Shared::BaseService
  def export_dump
    export_dump = "#{Rails.root}/tmp/export_files.csv"
    headers = ['ID', 'Export Name', 'Downloaded By', 'Created At']
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
      Export.all.each do |export|
        writer << [export.id, export.export_type.titlecase, export.created_by.to_s, export.created_at]
      end
    end
    temp_file = File.open(export_dump, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end
end
