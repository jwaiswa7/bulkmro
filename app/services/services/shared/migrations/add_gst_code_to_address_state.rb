class Services::Shared::Migrations::AddGstCodeToAddressState < Services::Shared::Migrations::Migrations
  def create_gst_code_entries
    @state_name = ''
    service = Services::Shared::Spreadsheets::CsvImporter.new('state_gst_codes.csv', 'seed_files_3')
    service.loop(nil) do |x|
      @state_name = x.get_column('name')
      address_state = AddressState.indian.where(name: @state_name).first
      if address_state.present?
        address_state.gst_code = x.get_column('gst_code')
      end
      address_state.save!
    end
  end
end
