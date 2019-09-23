class Services::Overseers::Targets::CreateAccountMonthlyTargets < Services::Shared::BaseService
  def initialize(account, annual_target)
    @account = account
    @annual_target = annual_target
  end

  # service -> when annual targets not present
  def call
    unless @annual_target.account_targets.present?
      current_date = Date.today
      # @annual_target = AnnualTarget.where(year: AnnualTarget.year_range.values).last
      initial_financial_month = ("#{current_date.year}-04-01").to_date
      current_month = ("#{current_date.year}-#{current_date.month}-01").to_date
      month_diff = (current_month.month - initial_financial_month.month) + 1
      changed_month = initial_financial_month
      month_diff.times.each do
        TargetPeriod.where(period_month: changed_month).first_or_create
        changed_month = changed_month + 1.month
      end
      target_periods = TargetPeriod.where(period_month: initial_financial_month..current_month)
      monthly_target = ((@annual_target['account_target'] * 100000) / 12.0).round(2)
      changed_monthly_target = monthly_target.round(2)
      target_periods.each do |target_period|
        target = AccountTarget.where(account_id: account.id, target_period_id: target_period.id).first_or_initialize(target_value: changed_monthly_target, annual_target_id: @annual_target.id)
        unless target.id.present?
          if target.save
            target_start_date = target_period.period_month.beginning_of_day
            target_end_date = (target_period.period_month + 1.month).beginning_of_day
            inquiries = @account.inquiries.where(status: 'Order Won').where(created_at: target_start_date..target_end_date)
            total_target_achieved = 0
            inquiries.each do |inquiry|
              if inquiry.bible_sales_orders.present?
                sales_order_total = inquiry.bible_sales_order_total
              else
                sales_order_total = inquiry.total_sales_orders.present? ? (inquiry.total_sales_orders.map { |so| so.calculated_total || 0 }.compact.sum) : 0
              end
              total_target_achieved += sales_order_total.round(2)
            end
            target_achieved_percentage = (total_target_achieved / monthly_target) * 100
            target.update_attributes(achieved_target: total_target_achieved, achieved_target_percentage: target_achieved_percentage)
            remaining_target = ((changed_monthly_target).to_f - total_target_achieved)
            changed_monthly_target = ((monthly_target).to_f + remaining_target)
          end
        end
      end
    end
  end

  attr_accessor :account, :annual_target
end
