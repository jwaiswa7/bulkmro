# frozen_string_literal: true

class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || hr?
  end

  def edit?
    (admin? || hr?)
  end

  def show?
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
  end

  def can_add_edit_target?
    record.role == 'inside_sales_executive' && (admin? || developer?)
  end
end
