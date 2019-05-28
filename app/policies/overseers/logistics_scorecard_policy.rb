# frozen_string_literal: true

class Overseers::LogisticsScorecardPolicy < Overseers::ApplicationPolicy
<<<<<<< HEAD

=======
  def index?
    true
  end

  def add_delay_reason?
    index?
  end
>>>>>>> 11b13e26b... change summary table start date to jan 2019, fix issue with updating delay reason, remove unwanted fields
end
