class Services::Overseers::Targets::SetMonthlyTarget < Services::Shared::BaseService
  # service -> when annual targets present
  def set_overseer_monthly_target
    overseer_ids = AnnualTarget.pluck(:overseer_id).uniq
    overseers = Overseer.where(id: overseer_ids)
    current_month = Date.today.at_beginning_of_month
    last_target_period = TargetPeriod.order(period_month: :asc).last.period_month
    month_diff = (current_month.month - last_target_period.month)
    month_diff.times.each do
      target_period = TargetPeriod.where(period_month: last_target_period + 1.month).first_or_create
      last_target_period = target_period.period_month
    end
    overseers.each do |overseer|
      overseer.set_monthly_target
    end
  end
end
