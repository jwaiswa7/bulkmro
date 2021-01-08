class Services::Shared::Migrations::AddLatestDataAsPerGov < Services::Shared::Migrations::Migrations
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

  def add_tax_code
    service = Services::Shared::Spreadsheets::CsvImporter.new('new_hsn_from_gov.csv', 'seed_files_3')
    service.loop(nil) do |x|
      code = x.get_column('Code')
      existing_tax_code = TaxCode.where(code: code)
      if !existing_tax_code.present?
        desc = x.get_column('Description')
        is_service = false
        # default to be 18%
        tax_percentage = 18
        is_active = x.get_column('is_active')
        remote_uid = x.get_column('Internal Key')
        is_active = true
        MeasurementUnit.create(remote_uid: remote_uid, code: code, description: desc, is_service: is_service, tax_percentage: tax_percentage, is_active: is_active )
      end
    end
  end

end
