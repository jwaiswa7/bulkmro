class Services::Shared::Migrations::AddLatestMeasurementUnits < Services::Shared::Migrations::Migrations
  def add_uoms
    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_uom.csv', 'seed_files_3')
    service.loop(nil) do |x|
      unit_code = x.get_column('Unit Code')
      unit_desc = x.get_column('Unit Description')
      MeasurementUnit.where('DATE(created_at) < ?', Date.new(2021, 01, 01)).each do |uc|
        if unit_code == uc.name.to_s
          uc.name = uc.name.humanize
          uc.save
        end
      end
      MeasurementUnit.create(name: unit_code, description: unit_desc)
    end
  end
end
