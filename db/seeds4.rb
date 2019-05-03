service = Services::Shared::Spreadsheets::CsvImporter.new('warehouses_remote_uids.csv', 'seed_files')
service.loop(nil) do |x|
  Warehouse.where(:name => x.get_column('Warehouse Name')).first_or_create do |warehouse|
    warehouse.legacy_metadata = x.get_row
    warehouse.build_address(
        :name => x.get_column('Account Name'),
        :street1 => x.get_column('Street'),
        :street2 => x.get_column('Block'),
        :pincode => x.get_column('Zip Code'),
        :city_name => x.get_column('City'),
        :country_code => x.get_column('Country'),
        :gst => x.get_column('GST'),
        :state => AddressState.find_by_region_code(x.get_column('State'))
    )
  end.update_attributes!(remote_uid: x.get_column('Warehouse Code'),
      legacy_id: x.get_column('Warehouse Code'),
      location_uid: x.get_column('Location'),
      remote_branch_name: x.get_column('Warehouse Name'),
      remote_branch_code: x.get_column('Business Place ID')
  )
end