# frozen_string_literal: true

class Overseers::CustomerProductPolicy < Overseers::ApplicationPolicy
  def generate_catalog?
    developer?
  end

  def destroy_all?
    developer?
  end

  def destroy?
    record.customer_order_rows.blank?
  end
end
