class Services::Resources::Addresses::SaveAndSync < Services::Shared::BaseService
  def initialize(address)
    @address = address
  end

  def call
    if address.save
      address.reload
      perform_later(address)
    end
  end

  def call_later
    address.company.save_and_sync
  end

  attr_accessor :address
end
