# frozen_string_literal: true

class Overseers::AnnualTargetPolicy < Overseers::ApplicationPolicy
  def new?
    admin_or_manager? || developer?
  end

  def edit?
    new?
  end

  def edit?
    new?
  end

  def show?
    admin_or_manager? || developer?
  end
end
