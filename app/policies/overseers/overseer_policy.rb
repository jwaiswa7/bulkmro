# frozen_string_literal: true

class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || hr?
  end

  def edit?
    (admin? || hr?)
  end

  def get_resources?
    true
  end

  def save_acl_resources?
    true
  end


  def edit_acl?
    developer? || overseer != record
  end

  def update_acl?
    developer? || overseer != record
  end

  def change_password?
    true
  end

  def update_password?
    edit?
  end

end
