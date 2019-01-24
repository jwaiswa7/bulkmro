
class Overseers::CompanyReviewPolicy < Overseers::ApplicationPolicy
  def update_rating?
    true
  end
  def render_form?
    true
  end
end