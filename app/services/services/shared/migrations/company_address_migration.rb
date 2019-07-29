class Services::Shared::Migrations::CompanyAddressMigration < Services::Shared::BaseService
  def company_addresses_dump
    file_name = "#{Rails.root}/tmp/company_addresses.csv"
    headers = ['company_name', 'street1', 'street2', 'state', 'country_code', 'gst', 'is_sez', 'created_by']
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
      Address.all.each do |address|
        company_name = address.company.present? ? address.company.to_s : 'Legacy'
        street1 = address.street1.present? ? address.street1 : ''
        street2 = address.street2.present? ? address.street2 : ''
        state = address.state.present? ? address.state.to_s : ''
        country_code = address.country_code.present? ? address.country_code : ''
        gst = address.gst.present? ? address.gst : ''
        is_sez = address.is_sez.present? ? address.is_sez : ''
        created_by = address.created_by.present? ? address.created_by.to_s : ''

        writer << [company_name, street1, street2, state, country_code, gst, is_sez, created_by]
      end
    end
    temp_file = File.open(file_name, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end
end
