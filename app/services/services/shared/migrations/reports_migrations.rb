class Services::Shared::Migrations::ReportsMigrations < Services::Shared::Migrations::Migrations
  # To fix pipeline report
  def change_lead_by_os_status_to_regret
    inquiries = Inquiry.where(status: 'Lead by O/S')
    inquiries.each do |inquiry|
      inquiry.status = 'Regret'
      inquiry.save(validate: false)
    end
  end
end

# s = Services::Shared::Migrations::ReportsMigrations.new
# s.change_lead_by_os_status_to_regret
