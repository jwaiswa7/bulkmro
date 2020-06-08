class Services::Shared::Migrations::MeasurementUnitDescriptionMigration < Services::Shared::Migrations::Migrations
  def update_measurement_unit
    service = Services::Shared::Spreadsheets::CsvImporter.new('measurement_unit.csv', 'seed_files_3')
    MeasurementUnit.all.each do |measurement_unit|
      service.loop(nil) do |x|
        if measurement_unit.name == (x.get_column('name'))
          bi = MeasurementUnit.where(name: x.get_column('name')).last
          bi.description = x.get_column('description')
          bi.save
        end
      end
    end
  end

  def missing_update
    missing_uom_names = MeasurementUnit.where(description: nil).pluck(:name)
    missing_uom_names.each do |name|
      bi = MeasurementUnit.where(name: name).last
      bi.description = name
      bi.save
    end
  end
end
