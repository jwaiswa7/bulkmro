class Services::Shared::Migrations::UpdateOverseers < Services::Shared::Migrations::MigrationsV2
    def update_overseers
      @invalid_ids = []
      service = Services::Shared::Spreadsheets::CsvImporter.new('overseers_updated_file.csv', 'seed_files_3')
      Chewy.strategy(:bypass) do

        service.loop do |row|
          id = row.get_column('id')
          name = row.get_column('name')
          first_name = name.strip.split(/\s+/)[0]
          last_name = name.strip.split(/\s+/)[1]
          email = row.get_column('email')
          status = row.get_column('status')
          mobile = row.get_column('contact')
          role = row.get_column('role')
          overseer = Overseer.where(id: id.to_i,email: email).last
          if overseer 
            overseer.assign_attributes(first_name: first_name,last_name: last_name,status: status,mobile: mobile,role: role)
            if !overseer.save
              @invalid_ids << id
            end
          else
            @invalid_ids << id
          end
        end
      end
      puts "Invalid Codes Array : #{@invalid_ids} \n \n #{ @invalid_ids.count}"
    end
  
end