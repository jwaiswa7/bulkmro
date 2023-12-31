# frozen_string_literal: true

class Overseers::InquiryImportPolicy < Overseers::ApplicationPolicy
  def manage_failed_skus?
    record.rows.failed.any? && record.excel?
  end

  def create_failed_skus?
    manage_failed_skus?
  end
end
