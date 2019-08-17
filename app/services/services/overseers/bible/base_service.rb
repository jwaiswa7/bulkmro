class Services::Overseers::Bible::BaseService < Services::Shared::BaseService

  def fetch_file_to_be_processed(upload_sheet)
    temp_path = Tempfile.open { |tempfile| tempfile << upload_sheet.bible_attachment.download }.path
    destination_path = Rails.root.join('db', 'bible_imports')
    Dir.mkdir(destination_path) unless Dir.exist?(destination_path)
    path_to_tempfile = [destination_path, '/', 'bible_file_sheet.rb'].join
    FileUtils.mv temp_path, path_to_tempfile
  end
end

