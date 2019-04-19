class Services::Shared::Migrations::MigrationsV2 < Services::Shared::Migrations::Migrations
  def call

    def create_ifsc_code
      service = Services::Shared::Spreadsheets::CsvImporter.new('ifsc_code_list.csv', 'seed_files')
      service.loop(limit) do |x|
        IfscCode.where(ifsc_code: x.get_column('IFSC')).first_or_create do |ifsc|
          ifsc.bank_id = Bank.where(name:x.get_column('BANK')).present? ? Bank.where(name:x.get_column('BANK')).last.id : nil
          ifsc.branch = x.get_column('BRANCH')
          ifsc.address = x.get_column('ADDRESS')
          ifsc.city = x.get_column('CITY')
          ifsc.district = x.get_column('DISTRICT')
          ifsc.contact = x.get_column('CONTACT')
          ifsc.state = x.get_column('STATE')
        end
      end
    end
  end
end
