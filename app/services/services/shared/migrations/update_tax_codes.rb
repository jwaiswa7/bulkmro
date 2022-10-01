class Services::Shared::Migrations::UpdateTaxCodes < Services::Shared::Migrations::MigrationsV2
    def update_tax_codes
      @invalid_codes = []
      service = Services::Shared::Spreadsheets::CsvImporter.new('HSN_SAC.csv', 'seed_files_3')
      Chewy.strategy(:bypass) do
        remove_extra_zeros_in_tax_code()

        service.loop do |row|
          code = row.get_column('HSN Desc')
          description = row.get_column('HSN Description')
          tax_code = TaxCode.where(code: code).last
          if tax_code
            tax_code.description = description
            tax_code.is_active = true
            tax_code.save(validate: false)
          else
            @invalid_codes << code
          end
        end
      end
      puts "Invalid Codes Array : #{@invalid_codes} \n \n #{ @invalid_codes.count}"
    end

    def remove_extra_zeros_in_tax_code
        TaxCode.all.each do |tax_code|
            tax_code.code = tax_code.code.to_i
            tax_code.save(validate: false)
        end
    end
  
  end