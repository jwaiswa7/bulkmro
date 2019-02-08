# frozen_string_literal: true

class Overseers::CompanyCreationRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || cataloging?
  end

  def requested?
    index?
  end

  def created?
    index?
  end

  def exchange_with_existing_company?
    index?
  end
end
