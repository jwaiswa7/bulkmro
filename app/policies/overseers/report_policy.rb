class Overseers::ReportPolicy < Overseers::ApplicationPolicy
  def index?
      manager_or_sales?
  end

  def show?
    if record.uid == 'target_report'
      ['vijay.manjrekar@bulkmro.com','prikesh.savla@bulkmro.com','ashwin.goyal@bulkmro.com','malav.desai@bulkmro.com','nilesh.desai@bulkmro.com','shravan.agarwal@bulkmro.com' ].include? overseer.email
    else
      manager_or_sales?
    end
  end
end