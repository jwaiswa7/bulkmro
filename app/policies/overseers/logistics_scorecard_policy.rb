# frozen_string_literal: true

class Overseers::LogisticsScorecardPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def add_delay_reason?
    index?
  end
end
