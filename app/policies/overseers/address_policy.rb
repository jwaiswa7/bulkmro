# frozen_string_literal: true

class Overseers::AddressPolicy < Overseers::ApplicationPolicy
  def edit_remote_uid?
    developer? && record.persisted?
  end

  def new?
    cataloging? || admin?
  end

  def edit?
    super && record.company.is_active if record.company.present?
  end

  def warehouse_addresses?
    true
  end

  def get_gst_code?
    true
  end
end
