class Services::Shared::Migrations::AddSeries < Services::Shared::Migrations::Migrations
  def call
    service = Services::Shared::Spreadsheets::CsvImporter.new('series.csv', 'seed_files')
    service.loop(nil) do |x|
      p x.get_column('period_ document_type')
      s = Series.new(
          :document_type => x.get_column('document_type'), :series => x.get_column('series'), :series_name => x.get_column('series_name'), :period_indicator => x.get_column('period_ indicator'), :number_length => x.get_column('length').to_i)
      p '******************8'
      # p s.errors.full_message
      s.save
      p '******************8'
    end
  end

  def set_series_last_number
    Series.all.each do |series|
      if series.last_number.nil? && series.first_number.present?
        json = { last_number: series.first_number }
        series.update_attributes(json)
      end
    end
  end
end
