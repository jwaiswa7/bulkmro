class Services::Shared::Migrations::MigrationsV3 < Services::Shared::Migrations::Migrations

  def change_daman_diu_gst_code
    # Daman and Diu gst code changed in august 2020 from 25 to 26, we have to keep previous gst for existing data
    address_state = AddressState.find(470)
    address_state.gst_code = 26
    address_state.legacy_metadata['gst_state_code'] = 26
    address_state.save
  end

end
