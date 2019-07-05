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
    # overseer != record
    true
  end

  def update_acl?
    true
<<<<<<< HEAD
  end

  def add_password_form?
    (admin? || hr?) && record != overseer
=======
>>>>>>> 9b9b9e6e2fe602351e784691b108e1a7c3fb3753
  end

  def update_password?
    edit?
  end

end
