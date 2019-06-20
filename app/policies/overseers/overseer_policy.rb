# frozen_string_literal: true

class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || hr?
  end

  def edit?
    (admin? || hr?) && record != overseer
  end

  def add_password_form?
    (admin? || hr?) && record != overseer
  end

  def update_password?
    edit?
  end

end
