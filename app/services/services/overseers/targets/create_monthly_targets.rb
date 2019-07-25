class Services::Overseers::Targets::CreateMonthlyTargets < Services::Shared::BaseService
  def initialize(overseer, annual_target)
    @overseer = overseer
    @annual_target = annual_target
  end

  def call
    unless @annual_target.targets.present?
      # overseer = Overseer.find(232)
      current_date = Date.today
      @annual_target = AnnualTarget.where(year: AnnualTarget.year_range.values).last
      initial_financial_month = ("#{current_date.year}-04-01").to_date
      current_month = ("#{current_date.year}-#{current_date.month}-01").to_date
      month_diff = (current_month.month - initial_financial_month.month) + 1
      # last_month = initial_financial_month + month_diff.month
      changed_month = initial_financial_month

      month_diff.times.each do
        TargetPeriod.where(period_month: changed_month).first_or_create
        changed_month = changed_month + 1.month
      end
      target_periods = TargetPeriod.where(period_month: initial_financial_month..current_month)
      Target.target_types.each do |target_type|
        target_type = 'Inquiry'
        coneverted_target_type = target_type.parameterize(separator: '_') + '_target'
        if @annual_target[target_type] != 0.0

          monthly_target = (@annual_target[coneverted_target_type] / 12.0).round(2)
          changed_monthly_target = monthly_target.to_i

          target_periods.each do |target_period|
            target = Target.where(overseer_id: overseer.id, target_period_id: target_period.id, target_type: Target.target_types[target_type]).first_or_initialize(target_value: changed_monthly_target, manager_id: @annual_target.manager_id, business_head_id: @annual_target.business_head_id, annual_target_id: @annual_target.id)
            unless target.id.present?
              if target.save
                target_start_date = target_period.period_month
                target_end_date = target_period.period_month + 1.month
                target_achieved = Inquiry.where(outside_sales_owner_id: overseer.id, status: 'Order Won').where(created_at: target_start_date..target_end_date).count

                remaining_target = (changed_monthly_target - target_achieved).to_i
                changed_monthly_target = (monthly_target.to_i + remaining_target)
              end
            end
          end
        end
      end
    end
  end

  attr_accessor :overseer, :annual_target
end
