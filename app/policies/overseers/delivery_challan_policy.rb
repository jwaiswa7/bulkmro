# frozen_string_literal: true

class Overseers::DeliveryChallanPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def new?
    manager_or_cataloging? || logistics?
  end

  def autocomplete_supplier?
    index?
  end
end

