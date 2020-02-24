class Services::Shared::Migrations::AddOsOwnerAnnualTargets < Services::Shared::Migrations::Migrations
  def add_annual_targets
    service = Services::Shared::Spreadsheets::CsvImporter.new('outside_sales_team_targets_2019.csv', 'seed_files_3')
    service.loop(nil) do |x|
      email = x.get_column('Email')
      manager_email = x.get_column('ManagerEmail')
      business_head_email = x.get_column('HeadEmail')
      overseer = Overseer.find_by_email(email)
      manager = Overseer.find_by_email(manager_email)
      business_head = Overseer.find_by_email(business_head_email)
      inquiry_target = x.get_column('Target FY1920').to_i
      if overseer.present?
        unless overseer.annual_targets.present? || inquiry_target == 0
          annual_target = overseer.annual_targets.build(manager_id: manager.id, business_head_id: business_head.id, year: '2019-2020', inquiry_target: inquiry_target)
          if annual_target.save
            service = Services::Overseers::Targets::CreateMonthlyTargets.new(overseer, annual_target)
            service.call
          else
            p overseer.email
          end
        end
      end
    end
  end

  def add_resource_reference
    annual_targets = AnnualTarget.where.not(overseer_id: nil)
    annual_targets.each do |annual_target|
      annual_target.resource_id = annual_target.overseer_id
      annual_target.resource_type = 1
      annual_target.save
    end
  end
end
