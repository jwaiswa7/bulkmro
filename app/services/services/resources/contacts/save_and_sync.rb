

class Services::Resources::Contacts::SaveAndSync < Services::Shared::BaseService
  def initialize(contact)
    @contact = contact
  end

  def call
    if contact.save
      perform_later(contact)
    end
  end

  def call_later
    contact.companies.each do |company|
      company.save_and_sync
    end
  end

  attr_accessor :contact
end
