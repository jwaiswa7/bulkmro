# frozen_string_literal: true

class Overseers::AccountPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging? || logistics?
  end
  def payment_collections?
    manager_or_cataloging? || logistics?
  end
  def ageing_report?
    manager_or_cataloging? || logistics?
  end
end
