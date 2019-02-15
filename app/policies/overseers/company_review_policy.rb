
class Overseers::CompanyReviewPolicy < Overseers::ApplicationPolicy
  def update?
    true
  end
  def render_form?
    true
  end
end
