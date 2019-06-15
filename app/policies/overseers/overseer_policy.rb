# frozen_string_literal: true

class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || hr?
  end

  def edit?
    (admin? || hr?) && record != overseer
  end

  def can_add_edit_target?
    record.role == 'inside_sales_executive' && (admin? || developer?)
  end
end
