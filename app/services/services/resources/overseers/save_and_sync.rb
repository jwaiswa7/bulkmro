class Services::Resources::Overseers::SaveAndSync < Services::Shared::BaseService
  def initialize(overseer)
    @overseer = overseer
  end

  def call
    if overseer.save
      perform_later(overseer)
    end
  end

  def call_later
    if overseer.salesperson_uid.present?
      ::Resources::SalesPerson.update(overseer.salesperson_uid, overseer)
    else
      salesperson_uid = ::Resources::SalesPerson.create(overseer)
      overseer.update_attributes(salesperson_uid: salesperson_uid) if salesperson_uid.present?
    end

    if overseer.employee_uid.present?
      ::Resources::EmployeeInfo.update(overseer.employee_uid, overseer)
    else
      employee_uid = ::Resources::EmployeeInfo.create(overseer)
      overseer.update_attributes(employee_uid: employee_uid) if employee_uid.present?
    end
  end

  attr_accessor :overseer
end
