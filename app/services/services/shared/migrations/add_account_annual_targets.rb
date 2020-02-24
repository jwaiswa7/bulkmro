class Services::Shared::Migrations::AddAccountAnnualTargets < Services::Shared::Migrations::Migrations
  def add_annual_targets
    service = Services::Shared::Spreadsheets::CsvImporter.new('account_targets.csv', 'seed_files_3')
    service.loop(nil) do |x|
      account_name = x.get_column('Account')
      account_target = x.get_column('Target').to_f
      account = Account.find_by(name: account_name)
      if account.present?
        unless account.annual_targets.present? || account_target == 0.0
          annual_target = account.annual_targets.build(account_target: account_target.round, resource_id: account.id, resource_type: 2)
          if annual_target.save
            service = Services::Overseers::Targets::CreateAccountMonthlyTargets.new(account, annual_target)
            service.call
          else
            p account.to_s
          end
        end
      end
    end
  end
end
