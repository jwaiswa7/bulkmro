namespace :tax_code do 
    
    desc 'Disable all the tax codes'
    task disable_all: :environment do 
        TaxCode.in_batches.update_all(is_active: false)
        TaxCodesIndex.import
    end
    
    desc 'Update all the tax codes'
    task update_all: :environment do 
        service =  Services::Shared::Migrations::UpdateTaxCodes.new(%w(update_tax_codes), folder: 'seed_files_3') 
        service.call

        TaxCodesIndex.import
    end
end

# rake tax_code:update_all