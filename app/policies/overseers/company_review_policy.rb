
class Overseers::CompanyReviewPolicy < Overseers::ApplicationPolicy
  def update_rating?
    true
  end

end