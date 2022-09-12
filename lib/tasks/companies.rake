namespace :companies do 
    
    desc 'update all logistics owner in companies'
    task update_logistics_owner: :environment do 
        service = Services::Shared::Migrations::AddDefaultLogisticsInCompany.new(%w(add_default_logistics_in_company), folder: 'seed_files')        
        service.call
    end
end