
class Overseers::CompanyReviewPolicy < Overseers::ApplicationPolicy
  def update?
    true
  end
  def render_form?
    true
  end
  def export_all?
    allow_export?
  end
  def export_filtered_records?
    export_all?
  end
end
