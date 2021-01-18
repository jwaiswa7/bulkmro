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


  # to upload new hsn, new_hsn_from_gov.csv should be run from below function
  # new_sac_code.csv
  #remaining_hsn_codes.csv
  def add_tax_code
    service = Services::Shared::Spreadsheets::CsvImporter.new('remaining_hsn_codes.csv', 'seed_files_3')
    existing_match = []
    new_hsn = []
    service.loop(nil) do |x|
      code = x.get_column('Code')
      existing_tax_code = TaxCode.where(code: code).last
      if !existing_tax_code.present?
        desc = x.get_column('Description')
        is_service = false
        # default to be 18%
        tax_percentage = 18
        remote_uid = x.get_column('Internal Key')
        is_active = true
        new_hsn.push(x)
        TaxCode.create(remote_uid: remote_uid, code: code, description: desc, is_service: is_service, tax_percentage: tax_percentage, is_active: is_active)
      else
        existing_match.push(existing_tax_code)
        existing_tax_code.created_at = Time.now
        existing_tax_code.save
      end
    end
    puts "existing_match - #{existing_match.count}"
    puts "new_hsn - #{new_hsn.count}"
  end

  def update_chapter_code
    tax_codes_with_chapter_nil = TaxCode.where(chapter: nil)
    tax_codes_with_chapter_nil.each do |tax_code|
      tax_code.chapter = tax_code.code.slice(0..3)
      tax_code.save
    end
  end


  def update_existing_hsn
    service = Services::Shared::Spreadsheets::CsvImporter.new('existing_hsn_update.csv', 'seed_files_3')
    existing_match = []
    no_match = []
    service.loop(nil) do |x|
      code = x.get_column('SPRINT Code')
      existing_tax_code = TaxCode.where(code: code).last
      if existing_tax_code.present?
        existing_match.push(existing_tax_code)
        existing_tax_code.created_at = Time.now
        existing_tax_code.save
      else
        no_match.push(code)
      end
    end
    puts "existing_match - #{existing_match.count}"
    puts "no_match - #{no_match.count}"
    puts no_match.inspect
  end
end
