class Services::Overseers::SaveAndSync < Services::Shared::BaseService

  def initialize(overseer)
    @overseer = overseer
  end

  def call
    if overseer.save
      if Rails.env.development?
        call_later
      else
        perform_later(overseer)
      end
    end
  end

  def call_later
    if overseer.salesperson_uid.present?
      Resources::SalesPerson.update(overseer.salesperson_uid, overseer)
    else
      overseer.salesperson_uid = Resources::SalesPerson.create(overseer)
    end
  end

  attr_accessor :overseer
end