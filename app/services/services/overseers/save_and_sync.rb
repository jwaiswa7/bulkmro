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

    #SalesPerson
    if overseer.salesperson_uid.present?
      Resources::SalesPerson.update(overseer.salesperson_uid, overseer)
    else
      overseer.salesperson_uid = Resources::SalesPerson.create(overseer)
      overseer.save
    end

    #EmployeeInfo
    if overseer.employee_uid.present?
      overseer.employee_uid = Resources::EmployeeInfo.update(overseer.employee_uid,overseer)
    else
      overseer.employee_uid = Resources::EmployeeInfo.create(overseer)
      overseer.save
    end
  end

  attr_accessor :overseer
end