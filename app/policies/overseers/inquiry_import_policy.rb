class Overseers::InquiryImportPolicy < Overseers::ApplicationPolicy
  def manage_failed_skus?
    record.rows.failed.any?
  end

  def create_failed_skus?
    manage_failed_skus?
  end
end