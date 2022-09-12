class Services::Shared::Migrations::AddDefaultLogisticsInCompany < Services::Shared::Migrations::MigrationsV2
  def add_default_logistics_in_company
    @invalid_remote_uid = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('client_mapping.csv', 'seed_files')
    Chewy.strategy(:bypass) do
      service.loop do |row|
        remote_uid = row.get_column('remote_uid')
        logistics_owner = row.get_column('logistics_owner')
        first_name = logistics_owner.split(/ /, 2).first
        last_name = logistics_owner.split(/ /, 2).last
        overseer = Overseer.where(first_name: first_name , last_name: last_name).last    
        company = Company.where(remote_uid: remote_uid).last
        if overseer && company
          company.logistics_owner_id = overseer.id
          company.save(validate: false)
        else
          @invalid_remote_uid << remote_uid
        end
      end
    end
    puts "Invalid Remote Uid Array : #{@invalid_remote_uid}"
  end

end